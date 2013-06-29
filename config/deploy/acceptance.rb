dir = '/var/apps/boardroom/acceptance'
secrets = %w(TWITTER_SECRET GOOGLE_CLIENT_SECRET FACEBOOK_APP_SECRET).map { |s| "$(cat #{dir}/config/#{s})"}.join ' '

set :branch, 'development'
set :deploy_to, dir
set :node_env, 'acceptance'
set :app_environment, "PORT=1338 #{secrets}"
