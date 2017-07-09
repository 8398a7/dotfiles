File.read('./extensions.txt').each_line do |extension|
  puts `code --install-extension #{extension.chomp}`
end
