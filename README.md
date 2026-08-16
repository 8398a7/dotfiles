# dotfiles

## セットアップ

### 1. リポジトリを取得する

```bash
git clone <this-repo> $HOME/dotfiles
```

`scripts/install.sh` は `$HOME/dotfiles` を前提にリンクを張るため、この配置以外では動かない。

### 2. mise でツールを入れる

nvim をはじめとした開発ツールは [mise](https://mise.jdx.dev/) で管理している。

```bash
# miseをインストール
curl https://mise.run | sh

# ツールをインストール
mise install
```

`mise install` が読む `~/.config/mise/config.toml` は現時点で dotfiles 管理外なので、新しいマシンでは手で用意する必要がある。最低限 nvim は以下で入る。

```bash
mise use -g 'aqua:neovim/neovim@latest'
```

### 3. dotfiles をリンクする

```bash
make install
```

`~/.config/nvim` は `nvim/` へのシンボリックリンクになる。初回の `nvim` 起動時に lazy.nvim が自動で clone され、プラグインがインストールされる。プロキシ環境では `git` の `http.proxy` 設定（`git/.gitconfig.local`）が必要。

### 4. 元に戻す

```bash
make clean
```

## ドキュメント

- [nvim の使い方](docs/nvim.md) — キーマップ・コマンド・カスタマイズした挙動
- [herdr の使い方](docs/herdr.md) — worktree 作成・キーバインドの方針

## make targets

```bash
$ > make
Usage: make <target>

environment
  install     install dotfiles
  clean       clean dotfiles

vscode
  install-extensions  install vscode extensions
  export-extensions  export vscode extensions
```
