# config valid only for current version of Capistrano
lock '3.3.5'

set :application, "positiv_flo"
set :user, "ubuntu"
set :repo_url, 'git@github.com:jonathanyeong/positiv-flo.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

set :deploy_to, "/home/ubuntu/apps/positiv_flo"
set :tmp_dir, "/home/ubuntu/tmp"
set :log_level, :debug

#set :delayed_job_workers, 2

#set :monit_delayed_job_workers, 2

set :monit_alert_email, "jay@thedevsquad.com"
#set :monit_alert_email_2, "operations@thirdpartytrade.com"
set :monit_email_username, "postmaster@sandboxa252e339dbd346c5bfb5155a36c7cd17.mailgun.org"
set :monit_email_password, "caf079b6b5d9606911661144feca51fe"

set :unicorn_workers, 3

set :linked_dirs, %w{tmp/pids tmp/sockets}

# set :slack_webhook, "https://hooks.slack.com/services/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"

namespace :deploy do

  desc "reload the database with seed data"
  task :seed do

    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "rake db:seed"
        end
      end
    end

  end

end

namespace :memcached do

  desc "Flushes memcached local instance"
  task :flush do
    on roles(:web, :app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "rake memcached:flush"
        end
      end
    end
  end

end

namespace :clockwork do
  desc "Stop clockwork"
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :clockworkd, "-c config/clock.rb --pid-dir=#{cw_pid_dir} --log-dir=#{cw_log_dir} --log stop"
        end
      end
    end
  end

  desc "Clockwork status"
  task :status do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :clockworkd, "-c config/clock.rb --pid-dir=#{cw_pid_dir} --log-dir=#{cw_log_dir} --log status"
        end
      end
    end
  end

  desc "Start clockwork"
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :clockworkd, "-c config/clock.rb --pid-dir=#{cw_pid_dir} --log-dir=#{cw_log_dir} --log start"
        end
      end
    end
  end

  desc "Restart clockwork"
  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :clockworkd, "-c config/clock.rb --pid-dir=#{cw_pid_dir} --log-dir=#{cw_log_dir} --log restart"
        end
      end
    end
  end

  def cw_log_dir
    "#{shared_path}/log"
  end

  def cw_pid_dir
    "#{shared_path}/tmp/pids"
  end

  def rails_env
    fetch(:rails_env, false) ? "RAILS_ENV=#{fetch(:rails_env)}" : ''
  end

end

# namespace :monit do
#
#   desc 'Generate config file for DJ process'
#   task :generate_dj_config do
#     on roles :app do
#       upload! monit_template('monit_delayed_job'), tmp_path('monit_delayed_job')
#       final_path('monit_delayed_job')
#     end
#   end
#
#   desc 'Generate config file for New Relic process'
#   task :generate_new_relic_config do
#     on roles :app do
#       upload! monit_template('monit_new_relic'), tmp_path('monit_new_relic')
#       final_path('monit_new_relic')
#     end
#   end
#
# end

# task :setup do
#   invoke 'monit:generate_dj_config' if fetch(:monit_configure_dj)
#   invoke 'monit:generate_new_relic_config' if fetch(:monit_configure_new_relic)
# end

after 'deploy:published', 'clockwork:restart'
after 'deploy:published', 'memcached:flush'


after 'deploy:restart', 'puma:restart'
