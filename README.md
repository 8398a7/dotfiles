# dotfiles

macOS / Linux 向けの zsh・Neovim・Git・VSCode・herdr 設定。開発用CLIは `mise.toml`、macOSのシステム依存とGUIアプリは `Brewfile` で管理する。

## セットアップ

Git 2.35以上、Python 3.11以上、zsh、makeを用意する。macOSでは必要に応じてHomebrewで `git python zsh` を入れる。Linuxではディストリビューションのパッケージを使う。

```sh
git clone <this-repo> <任意の配置先>
cd <配置先>
make install
```

リンク元はスクリプトの場所から解決する。`$HOME/dotfiles` への配置は不要。`XDG_CONFIG_HOME` / `XDG_STATE_HOME` は絶対パスで指定できる。VSCode設定はmacOSでは `~/Library/Application Support/Code/User/`、Linuxでは `$XDG_CONFIG_HOME/Code/User/` に配置する。IdeaVim設定もリンクする。

既存のファイル・ディレクトリは `$XDG_STATE_HOME/dotfiles/<checkout識別子>/`（既定は `~/.local/state/dotfiles/`）に退避し、`links.json` に復旧情報を残す。再実行で元のバックアップを上書きしない。旧ディレクトリのリンク元には書き込まず、無関係な設定は元データへのリンクで引き継ぐ。管理中のリンクを利用者が置き換えた場合は保持して中止する。復旧記録の保存先を置換対象ディレクトリ内に置く構成や、HOME以外のリンクした親ディレクトリ経由のXDG_CONFIG_HOMEは扱わない。

### CLIとmacOSアプリ

[miseの公式手順](https://mise.jdx.dev/getting-started.html)でmiseを導入する。`make install` によりグローバル設定がこのリポジトリの `mise.toml` を参照する。

```sh
mise trust ./mise.toml
mise install
exec zsh
```

既存のグローバルmise設定はバックアップされる。独自ツールの指定はバックアップを確認してプロジェクトの `mise.toml` 等へ移す。リポジトリのバージョンを変えると共有設定も変わるため、更新は差分を確認して行う。Go・Ruby・Python・Nodeの既定値はLSP導入用で、各プロジェクトの指定を優先する。データベース・サービス・protobuf等は必要なプロジェクト側で管理する。

macOSでは次も実行する。

```sh
brew bundle --file Brewfile
```

NeovimとVSCodeの表示には **JetBrainsMono Nerd Font** を使う。macOSはBrewfileで導入する。Linuxは[Nerd Fonts公式配布](https://www.nerdfonts.com/font-downloads)からユーザーのフォントディレクトリへ導入し、端末側でも選択する。VSCodeは `monospace` にフォールバックでき、zshプロンプトは特殊グリフを必要としない。

### エディタと補助ツール

Neovim初回起動時にlazy.nvimがプラグインを取得する。起動後に `:MasonInstallTools` を実行してLSP・リンタを導入する。プロジェクト指定の `goimports` 等は各プロジェクトで入れる。LinuxのクリップボードはWaylandなら `wl-clipboard`、X11なら `xclip` / `xsel` が必要。

```sh
make install-extensions   # VSCode CLIのcodeが必要
```

Vim本体・tmuxの設定とvendored powerlineは削除した。このリポジトリを指す既存の `.vim` / `.vimrc` / `.tmux` / `.tmux.conf` リンクはinstall時に除去する。他の場所を指すリンクや実ファイルは保持する。Neovimへの `vi` / `vim` エイリアス、IdeaVim、VSCodeのVimキーバインドは引き続き利用できる。

## 個人設定とGit hooks

共有Git設定の後に `$XDG_CONFIG_HOME/git/.gitconfig.local` を読み込む。認証・プロキシ・個別の署名鍵やユーザー情報はこのファイルで上書きし、リポジトリに含めない。旧 `~/.config/git` がディレクトリへのリンクだった場合も、既存のlocal設定を引き継ぐ。

GitHubのcredential helperはPATH上の `gh auth git-credential` を使う。`gh auth login` を個人環境で実行する。特定バージョンの実行ファイルパスや認証情報は配布しない。

`core.hooksPath` は共有設定で強制しない。このリポジトリのコミット前チェックを利用する場合は、このcheckoutで次を実行する。

```sh
git config --local core.hooksPath .githooks
```

他のプロジェクトへissue接頭辞を導入する場合は、`git/hooks/commit-msg` をそのプロジェクトのhookへ組み込んだ上で `git config --local dotfiles.issuePrefix true` を設定する。既存hookとの統合はプロジェクト側で行う。既定は無効で、`NO_TEMPLATE=true` はスキップ、`JIRA_PREFIX=ABC` は `ABC-123 ` 形式を選ぶ。繰り返し実行しても接頭辞を重ねない。

`git delete-merged-branches` は現在のブランチ、main/master/develop、各remoteの既定ブランチ、worktree使用中のブランチを保持する。remoteの既定名はキャッシュから読み、未取得なら問い合わせる。取得失敗時は削除を開始しない。pushは `simple`、pullは現在のupstreamを使う。

## 検証と更新

```sh
mise exec -- make check
```

Python 3.11以上、bash、zsh、Git、Neovimとjqが必要。`make check` は設定の構文と、一時HOMEを使うインストール／復元・Git・zsh・Neovimの動作を検証する。実ユーザーの設定を書き換えず、プラグインやツールの自動インストールも行わない。GitHub ActionsでもUbuntuとmacOSで同じチェックを行う。

miseのバージョンは `mise.toml`、zshプラグインのコミットは `zsh/plugins.toml`、Neovimプラグインは `nvim/lazy-lock.json` で固定する。更新後は `make check` と対話起動、必要な言語のLSP／フォーマッタを確認する。zshプラグイン更新後は `sheldon lock`、Neovimは `:Lazy update` で固定情報を更新する。Homebrewの古いロックは配布せず、Brewfileを正本とする。

`make export-extensions` は取得成功時だけ一覧をソートして置き換える。更新差分をレビューしてからコミットする。

## 元に戻す

```sh
make clean
```

このcheckoutが設置したリンクだけを除去し、退避した設定を復元する。利用者が変更・追加した設定は保持する。元のディレクトリが復元できない場合は非ゼロで終了し、バックアップと復旧記録を残す。別checkoutの `make clean` では、そのcheckoutの復旧記録だけを扱う。削除済みのVim/tmuxリンクは再作成しない。ツール・アプリ・フォントのアンインストールは行わない。

## ドキュメント

- [Neovimの使い方](docs/nvim.md)
- [herdrの使い方](docs/herdr.md)
- [レガシー調査66項目の対応表](docs/modernization.md)

利用できるmakeターゲットは `make help` で確認する。
