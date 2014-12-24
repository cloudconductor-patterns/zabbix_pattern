# Added by ChefSpec
require 'chef'
require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  pattern_root = File.expand_path('../../../', File.dirname(__FILE__))
  cookbook_root = File.expand_path('..', File.dirname(__FILE__))
  root_dir = File.exist?(File.join(pattern_root, 'metadata.yml')) ? pattern_root : cookbook_root
  config.cookbook_path = File.join(root_dir, 'cookbooks')
  config.role_path = File.join(root_dir, 'roles')
  config.log_level = :warn
  config.platform = 'centos'
  config.version = '6.5'
end
