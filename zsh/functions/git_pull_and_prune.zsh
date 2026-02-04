git_pull_and_prune() {
  # 現在のブランチをリモートからpull
  git pull origin $(git_current_branch_name) || return 1

  # リモートの参照を更新（削除されたブランチの参照も削除）
  git fetch --prune --tags --all

  # マージ済みのローカルブランチを削除（main, master, develop は除外）
  git branch --merged | grep -Ev '^\*|\s(main|master|develop)$' | xargs -r git branch -d
}
