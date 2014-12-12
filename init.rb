require 'redmine'

rails_root = File.dirname(__FILE__)

rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')[rails_env].symbolize_keys
Resque.redis = Redis.new(resque_config)
Resque.redis.namespace = resque_config[:namespace]

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_resque'
end

Redmine::Plugin.register :redmine_resque do
  name        'Resque for Redmine'
  description 'Background jobs for Redmine'
  author      'Undev'
  version     '0.0.3'
  url         'https://github.com/Undev/redmine_resque'

  requires_redmine :version_or_higher => '2.1'

  menu :top_menu, 'Resque', '/resque', :if => Proc.new { User.current.admin? }
end
