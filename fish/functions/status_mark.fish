function status_mark
  if test $argv -eq 0
    set_color green
    printf '✓ '
  else
    set_color red
    printf '𐄂'
  end
end
