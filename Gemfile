source 'https://rubygems.org'

gem 'rake'

group :development do
  gem 'guard'
  gem 'byebug'
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'guard-rubocop'
  gem 'cloud_conductor_utils', git: 'https://github.com/cloudconductor/cloud_conductor_utils.git', branch: 'develop'
end

group :test do
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'rspec_junit_formatter'
  gem 'guard-rspec', require: false
  gem 'spork'
  gem 'guard-spork'
  gem 'factory_girl'
  gem 'cloud_conductor_utils', git: 'https://github.com/cloudconductor/cloud_conductor_utils.git', branch: 'develop'
  gem 'chefspec'
  gem 'chef'
  gem 'berkshelf'
  gem 'foodcritic'
end
