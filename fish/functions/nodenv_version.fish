function nodenv_version
  nodenv version | awk '{print $1}'
end
