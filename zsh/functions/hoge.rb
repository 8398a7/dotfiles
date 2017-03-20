Dir.glob('./*.zsh').each do |file|
  p file
  `zsh -fc 'zcompile #{file}'`
end
