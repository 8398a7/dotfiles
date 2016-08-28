function peco_z_search
  if test (count $argv) = 0
    set query ''
  else
    set query --query $argv
  end
  sort -nr -t '|' -k 2 ~/.z | sed -e 's/|.*//' | peco $query | read result
  if [ $result ]
    commandline "cd $result"
    commandline -f execute
  else
    commandline ''
  end
end
