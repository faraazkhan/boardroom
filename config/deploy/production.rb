dir = '/var/apps/boardroom/production'
secrets = %w(TWITTER_SECRET GOOGLE_CLIENT_SECRET FACEBOOK_APP_SECRET).map { |s| "#{s}=$(cat #{dir}/config/#{s})"}.join ' '

set :branch, 'master'
set :deploy_to, dir
set :node_env, 'production'
set :app_environment, "PORT=1337 #{secrets}"
