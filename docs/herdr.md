# herdr の使い方

`herdr/` のカスタマイズ部分だけをまとめたもの。herdr 標準の操作は `prefix+?` のヘルプを見る。

prefix は `Ctrl+T`（tmux の設定に合わせている）。

- [worktree の作成](#worktree-の作成)
- [nvim ペイン連携](#nvim-ペイン連携)
- [ペイン移動を prefix 付きにしている理由](#ペイン移動を-prefix-付きにしている理由)

---

## worktree の作成

`prefix+Shift+G` で fzf が popup で開き、ブランチを選ぶと worktree ができてワークスペースとして開く。

- 候補にはローカルブランチと `origin/*` が混ざって出る（`origin/` は剥がして重複排除）
- 候補に無い名前をそのまま入力すれば新規ブランチになる
- `origin` が設定されている場合は、開くたびに `git fetch --prune origin` する
- fetch に失敗した場合は詳細を表示して Enter を待ち、ブランチ選択・worktree 作成を中止する（未取得の remote ブランチを新規名と誤認しないため）
- `origin` が無いリポジトリでは fetch を省略し、ローカルブランチの選択・新規作成を続けられる
- 既に worktree があるブランチを選ぶと、そのワークスペースにフォーカスが移るだけ

### 組み込みの new_worktree を使っていない理由

**herdr 組み込みの worktree 作成は、remote に同名ブランチがあってもそれを見ない。** 実行時の HEAD から新規ブランチを切るだけで、upstream も張らない（herdr 0.7.5 / 0.8.0 で実測）。

```
# origin に feature/hoge があり、ローカルには無い状態で:

$ herdr worktree create --branch feature/hoge
  -> HEAD の commit。upstream 無し（no upstream configured）

$ git wt feature/hoge
  -> origin/feature/hoge の commit。upstream = origin/feature/hoge
```

普通の `git checkout feature/hoge` と挙動が揃うのは後者。`git worktree add` の `worktree.guessRemote=true` を立てても herdr 側の挙動は変わらなかった。`herdr worktree open --branch` もローカルブランチが無いと `worktree_not_found` になるので、こちらでも救えない。

そこで **ブランチの解決は `git wt` に任せ、herdr には出来上がった worktree を `open` させるだけ**にしている。`config.toml` で組み込みの `new_worktree = ""` を無効化し、同じ `prefix+Shift+G` を `[[keys.command]]` の popup に割り当てて `herdr/bin/herdr-wt` を呼ぶ。

`git wt` が作る worktree（`wt.basedir` = `.worktrees`）は herdr が普通に認識するので、herdr 側の `[worktrees] directory`（`~/.herdr/worktrees`）は使わない。worktree はリポジトリ内に集まる。

### 詰まりどころ

- `herdr worktree open` は `--path` だけでは `not_git_worktree` になる。どのリポジトリの worktree かを `--cwd` でも示す必要がある
- popup は失敗メッセージを読む間もなく閉じるので、`herdr-wt` はエラー時に明示的に Enter を待つ
- `~/.config/herdr` にはログとソケットが生成されるためディレクトリごとリンクできない。`install.sh` は `config.toml` と `bin` を個別にリンクしている

## nvim ペイン連携

`<C-h/j/k/l>` で nvim のウィンドウ移動と herdr のペイン移動が繋がる。詳細は [nvim の使い方](nvim.md#herdr-ペイン連携)。

## ペイン移動を prefix 付きにしている理由

`focus_pane_*` は `prefix+h/j/k/l` のまま。**prefix 無しの `Ctrl+H/J/K/L` にはしない。** herdr がペイン内のアプリより先にキーを奪うので、シェルの `Ctrl+K`（kill-line）や `Ctrl+L`（clear）が効かなくなる（実測）。

nvim との連携はキーバインドではなく CLI 経由なので、prefix 付きでも成立する。
