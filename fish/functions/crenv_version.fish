function crenv_version
  crenv version | awk '{print $1}'
end

