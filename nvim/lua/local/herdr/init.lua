-- herdr のペイン移動と nvim のウィンドウ移動を <C-h/j/k/l> で繋ぐ
--
-- nvim 内にその方向のウィンドウがあればウィンドウを移動し、
-- 端にいるときだけ herdr にフォーカス移動を委譲する。
--
-- 公開プラグイン (herdr-splits.nvim など) は使わない。
-- herdr の CLI と環境変数だけで足りる規模で、いずれも登場が新しく成熟度が低い。
--
-- herdr 配下の判定は環境変数 HERDR_ENV で行う。

local M = {}

---@type table<string, string>
local DIRECTIONS = {
  h = 'left',
  j = 'down',
  k = 'up',
  l = 'right',
}

-- herdr へ委譲中かどうか。連打で呼び出しが積み上がるのを防ぐ。
-- vim.system は非同期なので、フォーカスが移る前に次のキーが来ると
-- 同じ方向へ二重に移動してしまう (herdr 側は移動できる限り移動する)。
local pending = false

-- herdr の CLI は失敗時に終了コード 1 と stderr を返す。stderr の形式は
-- 2 通りある (実測):
--   * サーバまで届いた場合: {"error":{"code":"pane_not_found",...}} の JSON
--   * ソケットに繋がらない場合: Error: Os { code: 2, kind: NotFound, ... }
-- JSON ならコードだけ取り出し、そうでなければ生のまま見せる。
---@param stderr string
---@return string
local function error_reason(stderr)
  stderr = vim.trim(stderr)
  local ok, decoded = pcall(vim.json.decode, stderr)
  if ok and type(decoded) == 'table' and type(decoded.error) == 'table' then
    return decoded.error.code or decoded.error.message or stderr
  end
  return stderr ~= '' and stderr or '原因不明'
end

---@param direction string 'left' | 'down' | 'up' | 'right'
local function focus_herdr_pane(direction)
  local cmd = { 'herdr', 'pane', 'focus', '--direction', direction }
  -- nvim が動いているペインを明示する。--current は「今フォーカスされている
  -- ペイン」なので通常は一致するが、ID を渡すほうが意図が明確。
  local pane = vim.env.HERDR_PANE_ID
  if pane and pane ~= '' then
    vim.list_extend(cmd, { '--pane', pane })
  else
    table.insert(cmd, '--current')
  end

  pending = true
  local ok, err = pcall(vim.system, cmd, { text = true }, function(result)
    pending = false
    -- 移動先が無いとき (reason: no_neighbor) は rc=0 の正常系。何も通知しない。
    if result.code == 0 then
      return
    end
    local reason = error_reason(result.stderr or '')
    vim.schedule(function()
      vim.notify(
        'herdr へのペイン移動に失敗しました: ' .. reason,
        vim.log.levels.WARN
      )
    end)
  end)
  -- herdr が PATH に無い場合は vim.system 自体が失敗する。
  -- エディタは止めず、警告だけ出す。
  if not ok then
    pending = false
    vim.notify('herdr コマンドを実行できません: ' .. tostring(err), vim.log.levels.WARN)
  end
end

--- <C-h/j/k/l> の移動。nvim 内で動けなければ herdr に委譲する。
---@param key 'h'|'j'|'k'|'l'
function M.navigate(key)
  local direction = DIRECTIONS[key]
  if not direction then
    error('local.herdr.navigate: 不正な方向 ' .. tostring(key))
  end

  -- その方向にウィンドウがあるか。無いときだけ winnr() と一致する。
  -- フローティングウィンドウ表示中は winnr('1h') が下のウィンドウを指すので
  -- 不一致になり、委譲せず wincmd に落ちる (実測)。
  if vim.fn.winnr('1' .. key) ~= vim.fn.winnr() then
    vim.cmd.wincmd(key)
    return
  end

  if vim.env.HERDR_ENV ~= '1' then
    return
  end
  if pending then
    return
  end
  focus_herdr_pane(direction)
end

function M.setup()
  for key in pairs(DIRECTIONS) do
    vim.keymap.set('n', '<C-' .. key .. '>', function()
      M.navigate(key)
    end, { desc = 'ウィンドウ / herdr ペインを移動 (' .. key .. ')' })
  end
end

return M
