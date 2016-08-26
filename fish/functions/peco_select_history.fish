function peco_select_history
  if test (count $argv) = 0
    set peco_select_history_query ''
  else
    set peco_select_history_query --query "$argv"
  end
  history | peco $peco_select_history_query | read select_history
  commandline $select_history
end
