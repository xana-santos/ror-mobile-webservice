server '52.63.74.132', user: 'ubuntu', roles: %w{web app db}
set :rails_env, "production"

set :puma_threads, [0, 5]

set :monit_configure_nginx, true

set :linked_files, %w{.env .env.production}

set :nginx_use_ssl, true
set :nginx_server_name, '52.63.74.132'