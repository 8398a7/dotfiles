function peco_select_history
  if test (count $argv) = 0
    set query ''
  else
    set query --query $argv
  end
  history | peco $query | read select_history
  commandline $select_history
end
