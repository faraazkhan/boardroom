set :branch, 'master'
set :deploy_to, '/var/apps/boardroom/production'
set :node_env, 'production'
set :app_environment, 'PORT=1337'

set :default_environment, {
  'TWITTER_KEY' => 'GTCNZRp7ZAzq5ByFyLk4cQ',
  'FACEBOOK_APP_ID' => '',
  'GOOGLE_CLIENT_ID' => '823996637625-ncfoctaop4ml75e8q6diuhbgl8jdiqvt.apps.googleusercontent.com'
}
