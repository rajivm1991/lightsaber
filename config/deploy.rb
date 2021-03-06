require 'mina/bundler'
require 'mina/git'
require 'mina/rvm'

set :user, 'lightsaber'
set :domain, 'lightsaber.captnemo.in'
set :deploy_to, '/home/lightsaber/lightsaber'
set :repository, 'https://github.com/captn3m0/lightsaber.git'
set :branch, 'master'
set :identity_file, 'lightsaber-deploy'
set :rvm_path, "$HOME/.rvm/scripts/rvm"

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
# set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
# Make sure that the deploy key is available
if ENV['CI'] === 'true'
  `openssl aes-256-cbc -K $encrypted_82a37ece568a_key -iv $encrypted_82a37ece568a_iv -in deploy-rsa -out lightsaber-deploy -d`
  `chmod 600 lightsaber-deploy`
end

task :environment do
  invoke :'rvm:use[default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
desc "Starts the current release"
task :setup => :environment do
  queue "cd ~/lightsaber/current"
  queue "bundle exec thin -C config.yml start"
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'bundle:install'

    to :launch do
        queue "echo Restarting thin server"
        queue! "bundle exec thin -C config.yml restart"
    end
  end
end