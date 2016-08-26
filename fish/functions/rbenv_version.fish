function rbenv_version
  rbenv version | awk '{print $1}'
end

