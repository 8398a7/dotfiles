function _peco_z_search
  if [ (count $argv) ]
    peco --query "$argv " |perl -pe 's/([ ()])/\\\\$1/g' | read result
  else
    peco perl -pe 's/([ ()])/\\\\$1/g' | read result
  end
  if [ $result ]
    commandline "cd $result"
    commandline -f execute
  else
    commandline ''
  end
end
function peco_z_search
  begin
    sort -nr -t '|' -k 2 ~/.z | sed -e 's/\|.*//'
  end | sed -e 's/\/$//' | awk '!a[$0]++' | _peco_z_search $argv
end
