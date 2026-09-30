autoload -Uz add-zsh-hook
__timetrack_threshold=${__timetrack_threshold:-10}
__timetrack_ignore_progs=(nvim zsh exec source git ssh herdr)

__my_preexec_start_timetrack() {
  __timetrack_start=$SECONDS
  __timetrack_command=$1
}
__my_preexec_end_timetrack() {
  [[ -n "${__timetrack_start:-}" ]] || return 0
  local elapsed=$((SECONDS - __timetrack_start))
  local line=${__timetrack_command:-} prog
  unset __timetrack_start __timetrack_command
  prog=${${(z)line}[1]}
  [[ ${__timetrack_ignore_progs[(Ie)$prog]} -ne 0 ]] && return 0
  (( elapsed >= __timetrack_threshold )) || return 0
  # argv carries arbitrary quotes/backslashes without compiling the command as AppleScript.
  osascript - "$elapsed" "$line" <<'APPLESCRIPT'
on run argv
  display notification ((item 1 of argv) & "sec : " & (item 2 of argv) & " done") with title "zsh" sound name "Purr"
end run
APPLESCRIPT
}
if [[ "$OSTYPE" == darwin* ]] && command -v osascript >/dev/null; then
  add-zsh-hook -d preexec __my_preexec_start_timetrack
  add-zsh-hook -d precmd __my_preexec_end_timetrack
  add-zsh-hook preexec __my_preexec_start_timetrack
  add-zsh-hook precmd __my_preexec_end_timetrack
fi
