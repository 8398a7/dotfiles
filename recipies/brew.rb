BREW_INSTALL_URL = 'https://raw.githubusercontent.com/Homebrew/install/master/install'

# Update brew
enable_update = node['brew']['enable_update'] ? node['brew']['enable_update'] : false
if enable_update
  execute 'Update brew' do
    command 'brew update'
  end
else
  Logger.info('Execution skipped Update brew because of not true enable_update')
end

# Upgrade brew
enable_upgrade = node['brew']['enable_upgrade'] ? node['brew']['enable_upgrade'] : false
if enable_upgrade
  execute 'Upgrade brew' do
    command 'brew upgrade'
  end
else
  Logger.info('Execution skipped Upgrade brew because of not true enable_upgrade')
end

# Install brew
execute 'Install brew' do
  command "ruby -e \'$(curl -fsSL #{BREW_INSTALL_URL})\'"
  not_if 'test $(which brew)'
end

# Add Repository
node['brew']['add_repositories'].each do |repo|
  execute 'Add Repository' do
    command "brew tap #{repo}"
    not_if "brew tap | grep -q '#{repo}'"
  end
end

# Install bin packages
node['brew']['install_packages'].each do |package|
  execute 'Install bin packages' do
    command "brew install #{package}"
    not_if "brew list | grep -q #{package}"
  end
end

# Install apps
node['brew']['install_apps'].each do |app|
  execute 'Install apps' do
    command "brew cask install #{app} --appdir=\'/Applications\'"
    not_if "brew cask list | grep -q #{app}"
  end
end

# Setup alfred
execute 'Setup alfred' do
  command 'brew cask alfred link'
end
