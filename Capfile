require 'capistrano/ext/multistage'
require 'capistrano/node-deploy'

set :stages, %w(acceptance production)
set :default_stage, 'acceptance'

set :application, 'boardroom'
set :repository,  'git://github.com/carbonfive/boardroom'
set :user, 'deploy'
set :scm, :git

role :app, 'boardroom.carbonfive.com'
