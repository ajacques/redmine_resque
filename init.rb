require 'redmine'

rails_root = File.dirname(__FILE__)
WORKER_SCHEDULE_FILE = File.join(Rails.root, 'config', 'worker_schedule.yml')
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')[rails_env].symbolize_keys
Resque.redis = Redis.new(resque_config)
Resque.redis.namespace = resque_config[:namespace]
Resque.schedule = YAML.load_file(WORKER_SCHEDULE_FILE) if File.file?(WORKER_SCHEDULE_FILE)

ActiveSupport::Dependencies.autoload_paths.push File.expand_path('../app/jobs', __FILE__)

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

  menu :top_menu, 'Resque', 'resque', :if => Proc.new { User.current.admin? }
end
