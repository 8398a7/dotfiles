# レガシー調査の対応記録

調査で列挙した66項目と実装の対応表。Vim本体・tmuxは削除し、Neovim・herdrを現行構成として扱う。

| No. | 調査対象 | 対応 |
| --- | --- | --- |
| 1 | installの無条件削除 | `scripts/links.py` で退避・復旧記録を持つリンク設置へ変更 |
| 2 | cleanの無条件削除 | 所有リンクだけ除去。利用者の置換・追加を保持し、復元できない場合は記録を残す |
| 3 | HOME/dotfiles固定 | スクリプト自身からcheckoutを解決 |
| 4 | 引用・XDG | パスを引用し、XDGの絶対パスと空白を扱う |
| 5 | macOS・diff-highlightの後始末 | VSCodeの復元も同じmanifestで管理。Homebrew配下のdiff-highlightリンクを操作しない |
| 6 | Linux VSCode・IdeaVim | OS別VSCodeパスとIdeaVimのリンクをmanifestへ追加 |
| 7 | 拡張一覧の上書き | 成功後だけ一時ファイルから置換、重複除去・ソート |
| 8 | Makefile PHONY | 全ターゲットをPHONYに登録 |
| 9 | 検証手段 | `make check`、隔離環境の回帰テスト、Ubuntu/macOS CIを追加 |
| 10 | mise未宣言 | `mise.toml` に共有CLIとLSP前提ランタイムを固定 |
| 11 | asdfとの二重管理 | Brewfileからasdfを削除しmiseへ集約 |
| 12 | Pythonの古い固定 | Python 3.14系へ変更。セットアップの最低要件は3.11 |
| 13 | 古いBrew lock | 削除。BrewfileをmacOSの正本にする |
| 14 | 未宣言CLI | fd、ripgrep、jq、git-wt、sheldon、herdr、Git LFS、sops、Terraform等を明示 |
| 15 | 旧DB・protobuf等 | 常駐サービス・プロジェクト依存をBrewfileから除き、プロジェクト側へ管理を移す |
| 16 | 任意ツール未導入での起動失敗 | mise・sheldon・fzf・git-wt・direnv等に存在チェックを追加 |
| 17 | fzfの多重導入・読み込み | miseのCLIと `fzf --zsh` に集約 |
| 18 | compinitの順序 | 補完のfpathを追加してからcompinit。ハイライトはwidget定義後に読む |
| 19 | TERM上書き | 呼び出し元のTERMを保持 |
| 20 | LANG固定 | 既存LANGを保持。未設定時は利用可能なlocaleを選ぶ |
| 21 | gf/fbrの重複 | 一つのref選択実装へ集約 |
| 22 | ブランチ表示の解析 | `git for-each-ref` の完全なrefを選択。remoteはtrack、tagはdetach |
| 23 | 名前空間切り詰め | symbolic-refで完全なブランチ名、detached時は短いcommitを表示 |
| 24 | tree表示からファイル抽出 | fdのNUL区切りを使う `fzf_file_nvim` へ置換 |
| 25 | 空白・キャンセル | fd/ghq/ssh/widgetの引用とキャンセル時の保持を実装 |
| 26 | zの固定幅cut | 生データのpath/rankを読み、順位を別フィールドとして選択 |
| 27 | worktreeの表示解析 | git-wtのJSONからpathを抽出し、NUL区切りで選択 |
| 28 | Bunの引用したチルダ | BUN_INSTALLの実パスから補完を読む |
| 29 | 過大な履歴 | 20万/10万に抑制。DOTFILES_HISTSIZE/SAVEHISTで変更可能 |
| 30 | 古いPATH | 個人Goソース・OpenSSL固定パスを除去。存在するbinとCargo環境を読む |
| 31 | pluginの機能重複 | ディレクトリ履歴はz、履歴検索はfzf。不要pluginを削除しrev固定 |
| 32 | AppleScript補間 | 経過時間はSECONDS、コマンド文字列はargvで渡す |
| 33 | 無条件kill -9 | 既定TERM、`--force` 指定時だけKILL |
| 34 | push matching | push simpleへ変更。master/develop固定pushを除去 |
| 35 | unstage | `restore --staged --` で作業内容を残す |
| 36 | ignores | `ls-files -ci --exclude-standard` で追跡済みignore対象を列挙 |
| 37 | merged branch削除 | 現在・既定・worktree使用中を保護。remote確認失敗時は削除前に中止 |
| 38 | commit-msg | リポジトリごとのopt-in、再実行の冪等性、本文と空白パスを保持 |
| 39 | global hooksPath | 共有設定の強制を削除。各プロジェクトで選択 |
| 40 | 未追跡の専用pre-commit | 元checkoutの個人hookを取り込まず、本リポジトリ用 `.githooks/pre-commit` にmake checkを用意 |
| 41 | 認証のバージョン絶対パス | PATH上のgh helperへ変更。認証状態・元checkoutの未コミット変更は配布しない |
| 42 | compactionHeuristic | 無効な古いオプションを削除 |
| 43 | Git editor | Neovimへ統一 |
| 44 | global ignoreの広すぎる除外 | 個人生成物だけに絞り、プロジェクト設定・vendor等を共有ignoreから除去 |
| 45 | powerlineの古い構文 | tmux/powerline一式を削除 |
| 46 | vendored powerline | 同上 |
| 47 | powerlineのcwd依存 | 同上 |
| 48 | pbcopy固定 | 同上 |
| 49 | 固定terminfo | 同上。zshもTERMを上書きしない |
| 50 | 頻繁な外部プロセス起動 | powerlineを削除。zshのGit情報はprecmdごとに計算 |
| 51 | WAN IPのHTTP取得 | powerline segmentを削除 |
| 52 | 廃止された外部API | 天気・地震・音楽等のsegmentを削除 |
| 53 | Python 2系の音楽連携 | segmentを削除 |
| 54 | 未使用segmentの不具合 | vendored segment全体を削除 |
| 55 | 古いハードウェア前提 | 同上 |
| 56 | Vim/Neovim二重管理 | Vim本体設定を全削除。Neovimを現行エディタにする |
| 57 | Vim filetype autocmd | 削除。Neovimは標準検出と必要なfiletype.addを使う |
| 58 | Markdownの空白除去 | Vim実装を削除。NeovimのMarkdown除外とVSCode設定を維持 |
| 59 | sudo保存の古い実装 | Vim実装を削除 |
| 60 | 未使用lightline処理 | Vim/lightlineを削除 |
| 61 | 全角空白match重複 | windowごとにmatch IDを確認して再登録を抑止 |
| 62 | クリップボード | ネイティブprovider優先。SSH/WSL条件でOSC 52を選び、pasteの戻り値も修正 |
| 63 | 実態と違う移行コメント | 削除済みファイル参照、古いツール未導入・VSCode説明を整理 |
| 64 | VSCode provider不足 | Terraform/Rustの設定と拡張一覧を一致させる |
| 65 | Ruby拡張の重複 | Ruby LSPへ集約 |
| 66 | フォントの不整合 | JetBrainsMono Nerd Fontへ統一。macOS宣言とLinux導入手順を追加 |

## 検証の範囲

`make check` は構文検証と一時HOME／一時リポジトリでの30件の回帰テストを実行する。ShellCheckで配布シェルスクリプト、actionlintでCI設定、StyLuaで変更したLuaファイルを検証した。新規HOMEへのmiseからのNeovim/jq導入とチェックも実行した。sheldonの実バイナリでも固定revの取得、補完の順序、ハイライトの読み込みを一時環境で確認した。

macOS固有パスの設置・復元はLinux上の隔離テストでも確認する。macOSの実機起動、GUIアプリ、デスクトップ通知、端末のOSC 52／ネイティブクリップボード、全言語のMason導入は実機確認が必要。Ubuntu/macOSのCIはpush後に動作する。

リンクは永続的に使うcheckoutから設置する。作業用worktreeでの変更を現在のHOMEへ適用することと、既存の個人ファイルを削除することは行っていない。
