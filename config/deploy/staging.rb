server '52.64.105.25', user: 'ubuntu', roles: %w{web app db}
set :rails_env, "staging"

set :puma_threads, [0, 5]

set :monit_configure_nginx, true

set :linked_files, %w{.env .env.staging}

set :nginx_use_ssl, true
set :nginx_server_name, '52.64.105.25'