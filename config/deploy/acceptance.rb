set :branch, 'development'
set :deploy_to, '/var/apps/boardroom/acceptance'
set :node_env, 'acceptance'
set :app_environment, 'PORT=1338'

set :default_environment, {
  'TWITTER_KEY' => 'm3OgDgomODpcbj0iwXXsw',
  'FACEBOOK_APP_ID' => '',
  'GOOGLE_CLIENT_ID' => '823996637625-ttq9v9vo4ohal1j8ggceq479fk62g2br.apps.googleusercontent.com'
}
