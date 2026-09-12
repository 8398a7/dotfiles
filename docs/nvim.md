# nvim の使い方

`nvim/` のカスタマイズ部分だけをまとめたもの。Vim 共通の操作は書かない。

leader は `<Space>`、localleader は `\`。

- [キーマップ](#キーマップ)
- [コマンド](#コマンド)
- [検索とファイル操作](#検索とファイル操作)
- [LSP](#lsp)
- [フォーマットと lint](#フォーマットと-lint)
- [デバッグ](#デバッグ)
- [Git](#git)
- [herdr ペイン連携](#herdr-ペイン連携)
- [クリップボード（WSL）](#クリップボードwsl)
- [設定を触るとき](#設定を触るとき)
- [困ったとき](#困ったとき)

---

## キーマップ

### 単独キー

旧 Vim 設定から引き継いだもの、および VSCode の指の習慣を残したもの。

| キー | 動作 | 出典 |
| --- | --- | --- |
| `<C-f>` | ファイルツリー（neo-tree）を開閉 | 旧 `:NERDTreeToggle` |
| `<C-b>` | バッファ一覧（fzf-lua） | 旧 `:tabnew` から変更 |
| `<C-n>` | 行番号（`number` / `relativenumber`）の表示を切り替え | 旧設定と同じ |
| `<C-h/j/k/l>` | ウィンドウ移動、端なら herdr のペイン移動 | 新規 |
| `-` | 親ディレクトリを oil で開く | 新規 |
| `<Esc>` | 検索ハイライトを消す（`:nohlsearch`） | 新規 |

`<C-b>` を `:tabnew` から変えたのは、nvim ではタブよりバッファ中心の運用にしたため。タブが必要なときは `:tabnew` / `gt` / `gT` を使う。

### 挿入モードの Emacs バインド

旧設定から全部そのまま移植している。

| キー | 動作 |
| --- | --- |
| `<C-j>` | ノーマルモードに戻る |
| `<C-a>` / `<C-e>` | 行頭 / 行末 |
| `<C-b>` / `<C-f>` | 左 / 右 |
| `<C-n>` / `<C-p>` | 下 / 上 |

補完メニューが出ている間もこれらは効く。blink.cmp 側で `<C-b>` / `<C-f>` / `<C-e>` の割り当てを外し、ドキュメントのスクロールを `<C-u>` / `<C-d>`、キャンセルを `<C-g>` に移してある。`<C-n>` / `<C-p>` はメニュー表示中だけ候補選択になり、非表示時は上下移動に落ちる（両立する）。

### コマンドラインモード

| キー | 動作 |
| --- | --- |
| `w!!` | sudo を付け忘れたときに `tee` 経由で保存し直す |

保存に成功したときだけファイルを再読込する。sudo の認証や書き込みに失敗した場合は、未保存の編集内容をバッファに残す。

### leader 系

`<leader>f` = finder、`<leader>g` = Git、`<leader>d` = デバッグ、`<leader>e` = 診断。

キーマップを忘れたら `<leader>fk` で全部一覧して絞り込める。

---

## コマンド

| コマンド | 動作 |
| --- | --- |
| `:Format` | バッファを整形（範囲指定可: `:'<,'>Format`） |
| `:FormatDisable` | 保存時フォーマットを全体で無効化 |
| `:FormatDisable!` | 保存時フォーマットをこのバッファだけ無効化 |
| `:FormatEnable` | 保存時フォーマットを有効化 |
| `:Lint` | linter を手動実行 |
| `:LspRestart [名前...]` | LSP サーバを再起動（省略時は現在のバッファのもの） |
| `:MasonInstallTools` | 宣言済みの Mason ツールをまとめて入れる |
| `:Neotree toggle` / `:Oil` | ファイルツリー / ディレクトリバッファ |
| `:FzfLua` | fzf-lua の機能一覧 |

`:LspRestart` は lspconfig 付属のものを自前実装で置き換えている。この構成は `lspconfig.setup()` を呼ばないので、本来の `:LspRestart` はサーバを止めたまま再起動しない。

---

## 検索とファイル操作

### fzf-lua

zsh 側の fzf と操作感を揃えてある（`--cycle --exact`、`ivy` プロファイルで画面下部に横長表示）。

**`--exact` なのであいまい検索は既定でオフ。** あいまい検索したいときはクエリの先頭に `'` を付けると fzf が反転してくれる。

| キー | 対象 |
| --- | --- |
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | grep（live_grep） |
| `<leader>fb` / `<C-b>` | バッファ一覧 |
| `<leader>fh` | 最近開いたファイル |
| `<leader>fl` | このバッファ内を検索 |
| `<leader>fw` | カーソル下の単語を grep（visual で選択範囲） |
| `<leader>fr` | 直前の検索を再開 |
| `<leader>fc` / `<leader>fC` | コミット履歴 / このファイルのコミット履歴 |
| `<leader>fs` / `<leader>fB` | 変更のあるファイル / ブランチ一覧 |
| `<leader>fd` / `<leader>fD` | このファイルの診断 / ワークスペースの診断 |
| `<leader>fo` / `<leader>fO` | このファイルのシンボル / ワークスペースのシンボル |
| `<leader>fR` / `<leader>fi` | 参照一覧 / 実装一覧 |
| `<leader>fk` | キーマップ一覧 |
| `<leader>f?` | fzf-lua の機能一覧 |

LSP 系がここにあるのは「一覧から選ぶ」用途のもの。単発ジャンプは `gd` / `grr` など（[LSP](#lsp) 参照）。

`vim.ui.select` も fzf に差し替えてあるので、コードアクションの選択などもこの UI で出る。

### grep を特定ディレクトリに絞る

`<leader>fg` のクエリの後ろに **` -- `**（スペース + `--` + スペース）を付けて glob を書く。

```
Foo -- pkg/**              pkg/ 以下だけ
Foo -- !*_test.go          テストファイルを除く
Foo -- pkg/** !*_test.go   併用（スペース区切りで複数）
```

`!` 始まりが除外。glob は `--iglob` として渡されるので**大文字小文字を区別しない**（区別したいときは `glob_flag = '--glob'` を設定する）。

**glob はパスのパターンなので、ディレクトリ名だけでは効かない。** `-- pkg` ではなく `-- pkg/**` と書く。

同じディレクトリを何度も検索するなら `cwd` を渡すほうが楽。rg の検索起点そのものが変わる。

```
:FzfLua live_grep cwd=pkg
```

### 検索から外しているもの

`nvim/rgignore` に集めている。実質 `vendor/` の除外が中心。git 追跡されている vendor は `.gitignore` では落ちないため、別の ignore ファイルを使う。

**`alt-i` で一時的に戻せる。** vendor の中を見たいときはこれ。`.git/` は `alt-i` でも出ないよう別扱い（`lua/plugins/finder.lua` の rg グロブ側）にしてある。

**上の glob 指定では戻せない。** vendor を glob で指定しても `No files were searched` になる。`--ignore-file` の除外は別レイヤーで効いていて、glob は検索対象の絞り込みしかできないため。vendor の中を見るのは `alt-i` だけ。

### ファイルツリー

役割を 2 つに分けている。

- **oil.nvim**（`-`）— ディレクトリをバッファとして開く。ファイルの作成・削除・リネームを普通のテキスト編集としてやって `:w` で確定する。主力。
- **neo-tree**（`<C-f>`）— 従来型のサイドバー。`<leader>fe` で現在のファイルの位置を表示。ツリーだけが残ったら nvim を閉じる（旧 NERDTree 設定と同じ挙動）。

どちらもドットファイルを表示する。neo-tree は `.git` / `node_modules` / `vendor` を隠す。

---

## LSP

### キーマップ

**nvim 0.11 以降の標準キーマップをそのまま使う。** 標準に無い 3 つだけ足している。

| キー | 動作 | 出所 |
| --- | --- | --- |
| `gd` | 定義へ移動 | 追加 |
| `K` | ホバー | 追加 |
| `<leader>e` | 診断をフロートで表示 | 追加 |
| `grn` | リネーム | nvim 標準 |
| `gra` | コードアクション（visual も可） | nvim 標準 |
| `grr` | 参照 | nvim 標準 |
| `gri` | 実装 | nvim 標準 |
| `grt` | 型定義 | nvim 標準 |
| `grx` | codelens 実行 | nvim 標準 |
| `gO` | ドキュメントシンボル | nvim 標準 |
| `i_<C-s>` | シグネチャヘルプ | nvim 標準 |
| `]d` / `[d` | 次 / 前の診断 | nvim 標準 |

### 診断の表示

`virtual_text` は使わず **`virtual_lines`（カーソル行だけ）** にしてある。行末表示は長いメッセージが切れるため、コードの下に複数行で出す。

サインは `signcolumn = 'yes'` で常時確保しているので、診断が出てもテキストが左右にずれない。

### サーバの設定を変えたいとき

`nvim/after/lsp/<name>.lua` に **差分だけ** 書く。ベースは nvim-lspconfig の定義。

`after/` でなければならない。`lsp/*.lua` は runtimepath 上の同名ファイルを順に `tbl_deep_extend('force')` で畳み込むため後に読まれた方が勝つが、`~/.config/nvim/lsp` は lazy のプラグインより先に来るので lspconfig に負ける。

有効化するサーバの一覧は `nvim/lua/plugins/lsp.lua` の `servers`。

### Mason

`PATH = 'append'` にしてある。プロジェクト側で固定されたバージョン（mise shims / `node_modules/.bin`）が優先され、Mason 版は隠れる。

そのため以下は **Mason で入れない**（二重管理を避けるため最初から宣言していない）。

- `goimports` / `revive` / `staticcheck` — プロジェクト側の `mise.toml` で固定

新しいマシンでは `:MasonInstallTools` を叩く。起動時に自動で走らせないのは、プロキシ環境で起動が遅くなり、ミラー障害時に毎回失敗するため。

### 補完（blink.cmp）

`<Tab>` で確定、スニペット展開中は次のプレースホルダへ（super-tab プリセット）。

**先頭候補は自動選択されない。** `<Tab>` が `select_and_accept` なので preselect すると、インデント目的の `<Tab>` が意図しない候補を挿入してしまう。

| キー | 動作 |
| --- | --- |
| `<Tab>` / `<S-Tab>` | 確定・次のプレースホルダ / 前のプレースホルダ |
| `<C-n>` / `<C-p>` | 候補を選択（メニュー非表示時は上下移動） |
| `<C-space>` | 候補・ドキュメントの表示切り替え |
| `<C-u>` / `<C-d>` | ドキュメントをスクロール |
| `<C-g>` | キャンセル |
| `<C-k>` | シグネチャの表示切り替え |

Go だけスニペットのソースを外している（VSCode の `[go] editor.snippetSuggestions = "none"` と同じ）。

---

## フォーマットと lint

### 保存時フォーマット

conform.nvim が担当。**LSP のフォーマットは使わない**（`lsp_format = 'never'`）。

| filetype | 保存時 | `:Format` 時 |
| --- | --- | --- |
| go | goimports | 同じ |
| lua | stylua | 同じ |
| terraform / hcl | terraform_fmt | 同じ |
| proto | buf | 同じ |
| sh / bash / zsh | shfmt | 同じ |
| rust | rustfmt | 同じ |
| **json / jsonc / yaml** | **末尾空白の除去だけ** | prettier |
| **markdown** | **何もしない** | 何もしない |
| その他 | 末尾空白・末尾空行の除去 | 同じ |

**json / yaml で保存時に prettier を走らせないのは意図的。** 既存ファイルとスタイルが合わないプロジェクトで、保存するだけで無関係な差分が混ざるのを避けるため、prettier は `:Format` を明示的に叩いたときだけ走る。

**markdown はフォーマッタを入れていない。** 行末 2 スペースの改行が意図的なので末尾空白も消さない。

フォーマッタのバイナリが無いリポジトリでは黙って飛ばされる（prettier はグローバルに入れていないため、プロジェクト側に無ければ自動的に無効）。

生成ファイルや他人のコードを触るときは `:FormatDisable!`（このバッファだけ）。

### lint

nvim-lint が LSP のカバー範囲外を補う。保存後・読み込み後・insert を抜けたときに走る。

| filetype | linter |
| --- | --- |
| go | revive |
| sh / bash | shellcheck |
| terraform | tflint |

**`go vet` は移植していない。** gopls が同じ analyzer を内蔵していて、`printf` / `copylocks` / `unreachable` / `assign` を含む go vet の指摘をすべて出す上に staticcheck 由来のもの（SA5008 など）も追加で出す。go vet の起動は 1.27 秒かかるので重複分を丸ごと削った。

revive は**カーソル位置のディレクトリ単位**で走る。ファイルパスを直接渡すと vendor のあるリポジトリで `import lookup disabled by -mod=vendor` になるため。リポジトリ直下の `revive.toml` があれば自動で使う。

linter のバイナリが無いリポジトリでは黙って飛ばす。

---

## デバッグ

nvim-dap。**キーを押すまでロードされない**ので、デバッグしない日は起動に影響しない。

### キーマップ

VSCode と同じ F キーを残しつつ、`<leader>d` 側にも同じものを置いている。

| キー | 動作 |
| --- | --- |
| `<F5>` / `<leader>dc` | 開始・続行 |
| `<F10>` / `<leader>dO` | ステップオーバー |
| `<F11>` / `<leader>di` | ステップイン |
| `<F12>` / `<leader>do` | ステップアウト |
| `<leader>dx` | 終了 |
| `<leader>dl` | 直前の構成でもう一度 |
| `<leader>db` / `<leader>dB` / `<leader>dL` | ブレークポイント / 条件付き / ログポイント |
| `<leader>de` | カーソル下・選択範囲の値を見る |
| `<leader>du` / `<leader>dr` | デバッグ UI / REPL の開閉 |
| `<leader>dt` / `<leader>dT` | カーソル位置のテスト / 直前のテストをデバッグ |

**VSCode の `Shift+F5`（停止）は入れていない。** `TERM` が `xterm-256color` なので端末が Shift+F キーを送らず、押しても効かないキーが `<leader>fk` の一覧に並ぶだけになる。停止は `<leader>dx`。

UI はセッション開始で自動的に開くが、**終了時に自動では閉じない**（停止した瞬間の変数やスタックを見返したいことが多いため）。閉じるのは `<leader>du`。

### Go

delve を使う。Mason で入る。`dlv` が無いときは `:MasonInstallTools` への導線が出る（素の nvim-dap は「adapter の定義を直せ」という的外れなメッセージを出すので差し替えてある）。

**ビルドが通らないコードでデバッグ起動すると REPL が自動で開く。** delve はビルドエラーの本文を output イベントで送るが、launch のエラーレスポンス側には `showUser = false` で「Check the debug console for details.」しか入れてこない。nvim-dap は `showUser` を尊重するので、放っておくと画面には「Error on launch」だけが出てどこが間違っているのか分からない。

コンテナ内 delve への remote attach は入れていない。必要になったら追加する。

---

## Git

2 段構成。**コミット・ブランチ操作そのものは持ち込んでいない**（zsh 側に `fzf_git` / `glg` / `gps` などが揃っているのでそちらを使う）。fugitive も入れていない。

### gitsigns（日常操作）

git リポジトリのバッファに自動でアタッチする。

| キー | 動作 |
| --- | --- |
| `]c` / `[c` | 次 / 前の変更へ（diff モード中は素の `]c` に任せる） |
| `<leader>gs` / `<leader>gr` | hunk をステージ / 元に戻す（visual で範囲指定可） |
| `<leader>gS` / `<leader>gR` | バッファ全体をステージ / 元に戻す |
| `<leader>gp` | hunk の差分をプレビュー |
| `<leader>gd` | インデックスとの差分を開く |
| `<leader>gb` / `<leader>gB` | 行末 blame の表示切り替え / この行の blame |
| `ih` | hunk をテキストオブジェクトとして選択（`dih` / `vih`） |

行末 blame は既定でオフ。情報量が多くて邪魔になりやすいので、必要なときだけ `<leader>gb`。

### diffview（まとめて見る）

| キー | 動作 |
| --- | --- |
| `<leader>gv` | 変更全体の差分を開く |
| `<leader>gh` | このファイルの履歴（visual で選択範囲の履歴） |

差分は左右に並べる。

### 一覧から選ぶ

コミット一覧・ブランチ一覧の閲覧は fzf-lua 側（`<leader>fc` / `<leader>fB` / `<leader>fs`）。

---

## herdr ペイン連携

`<C-h/j/k/l>` で **nvim のウィンドウ移動と herdr のペイン移動が繋がる。** その方向に nvim のウィンドウがあればウィンドウを移動し、端にいるときだけ herdr にフォーカスを委譲する。

公開プラグイン（herdr-splits.nvim など）は使わず、herdr の CLI と環境変数だけで実装している（`nvim/lua/local/herdr/init.lua`）。

**herdr 配下かどうかは `HERDR_ENV` で判定する。** 未設定なら委譲しないので、素の WSL ターミナルでも tmux 内でも「nvim 内のウィンドウ移動だけ」に自動的に倒れる。tmux 側は prefix 付きのままなので二重発火しない（`tmux/.tmux.conf` に手を入れる必要はない）。

移動先が無いとき（`no_neighbor`）は何も通知しない。`herdr` が PATH に無いときやソケットに繋がらないときだけ警告が出る。

連打で呼び出しが積み上がらないよう、委譲中は次の委譲を抑止している（`vim.system` が非同期なので、フォーカスが移る前に次のキーが来ると同じ方向へ二重に移動してしまう）。

**herdr 側のペイン移動は `prefix+h/j/k/l` のまま。** 委譲は CLI 経由なので、herdr 側を prefix 無しにする必要はない。

一度 `ctrl+h/j/k/l` に変えたが戻した。herdr はペイン内のアプリより先にキーを奪うので、**nvim 以外のペインで以下が全部死ぬ**（実測）。

| 押したキー | 送るバイト | 奪う設定 |
| --- | --- | --- |
| `Ctrl+K`（kill-line） | 0x0B | `focus_pane_up = "ctrl+k"` |
| `Ctrl+L`（clear） | 0x0C | `focus_pane_right = "ctrl+l"` |
| **`Shift+Enter`** | **0x0A（`Ctrl+J` と同一）** | `focus_pane_down = "ctrl+j"` |
| `prefix+l` / `prefix+→` | — | `focus_pane_right` の上書きで消える |

**`Shift+Enter` は `Ctrl+J` と同じバイト（LF）なので端末は区別できない。** `ctrl+j` を奪うと Claude Code などの `Shift+Enter` 改行が巻き添えで死ぬ。症状とキーの見た目が繋がらないので気づきにくい。

---

## クリップボード（WSL）

`clipboard = 'unnamedplus'` + **OSC 52**。ヤンクした内容は端末経由で Windows 側のクリップボードに渡る。

**逆方向（Windows → nvim）は OSC 52 では取れない。** 応答を返さない端末が多いので、`"+p` は nvim 内の無名レジスタを返すようにしてある。Windows のクリップボードから貼るときは端末側のペースト（`Ctrl+Shift+V` など）を使う。

---

## 設定を触るとき

### ファイル配置

```
nvim/
  init.lua              エントリポイント（leader の設定だけ）
  lua/config/           options / keymaps / autocmds / lazy
  lua/plugins/<name>.lua  プラグインの spec。1 ファイル 1 テーマ
  lua/local/<name>/     自作プラグイン（herdr 連携など）
  lsp/<name>.lua        lspconfig に定義が無いサーバ
  after/lsp/<name>.lua  lspconfig の定義への差分
  rgignore              fzf-lua の検索除外
  .stylua.toml          このディレクトリの整形設定
  lazy-lock.json        プラグインのバージョン固定（追跡する）
```

`lua/plugins/` は lazy.nvim が自動 import する。ファイルを足せば読まれる。

### 自作プラグインを足すとき

`lua/local/<name>/` に置き、`lua/plugins/local.lua` に spec を書く。

**`dir` はプラグインごとに別のパスにする。** lazy.nvim は `dir` をプラグインの同一性の判定に使うため、同じ `dir` を持つ複数の spec は「1 つのプラグインの別フラグメント」として統合される。

### colorscheme

catppuccin mocha、背景は透過（端末に任せる）。herdr の `config.toml` が `[theme] name = "catppuccin"`、`accent = "#a6e3a1"`（mocha の green）を指定しているのでペインの枠と揃う。

**プラグインを足したら `integrations` に明示する。** catppuccin は `auto_integrations` で自動検出するが、コンパイル済みキャッシュのハッシュはユーザ設定だけから作られていて検出結果を含まない。つまりプラグインを後から足してもキャッシュが再生成されず、そのプラグインのハイライトが定義されないままになる（nvim-dap を足した直後に `DapBreakpoint` が undefined になった）。`integrations` に書けば設定のハッシュが変わるので確実に反映される。急ぎなら `:CatppuccinCompile`。

### filetype 検出を足すとき

`lua/config/autocmds.lua` の `vim.filetype.add`。nvim 0.12 のデフォルトで足りないものだけ足している（`.slim` / `.gotmpl` / `.gohtml` / `.mdx` / nginx のパスパターン）。

### treesitter

`main` ブランチを使っている（`master` は 0.11 互換で凍結）。パーサの一覧は `lua/plugins/treesitter.lua`。足すとその場でインストールされる。

パーサが無い filetype（`.slim` など）は従来の正規表現 syntax にフォールバックする。`synmaxcol = 200` はそのときの保険（treesitter はこの値を見ない）。

---

## 困ったとき

| 症状 | 見るところ |
| --- | --- |
| 保存しても整形されない | `:ConformInfo` でフォーマッタの available を確認。json / yaml / markdown は意図的に走らない |
| 診断が出ない | `:checkhealth vim.lsp` でアタッチ状況。linter は `:Lint` で手動実行 |
| LSP が変な状態になった | `:LspRestart` |
| プラグインの状態を見たい | `:Lazy` |
| キーマップを忘れた | `<leader>fk` |
| 全体の健康診断 | `:checkhealth` |
