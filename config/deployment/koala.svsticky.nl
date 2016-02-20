upstream app {
	server unix:/tmp/unicorn.sock fail_timeout=0;
}

server {
	listen 80;
	server_name koala.svsticky.nl koala.stickyutrecht.nl;
	return 301 https://koala.svsticky.nl$request_uri;
}

server {
	listen 80;
	server_name intro.svsticky.nl intro.stickyutrecht.nl;
	return 301 https://intro.svsticky.nl$request_uri;
}

server {
	listen 443 ssl;
	server_name koala.stickyutrecht.nl;

	ssl_certificate /etc/letsencrypt/live/koala.svsticky.nl/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/koala.svsticky.nl/privkey.pem;

	return 301 https://koala.svsticky.nl$request_uri;
}

server {
	listen 443 ssl;
	server_name intro.stickyutrecht.nl;

	ssl_certificate /etc/letsencrypt/live/koala.svsticky.nl/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/koala.svsticky.nl/privkey.pem;

	return 301 https://intro.svsticky.nl$request_uri;
}

server {
	listen 443 ssl;
	server_name koala.svsticky.nl intro.svsticky.nl;

	# HSTS not configured here, is already enforced in /var/www/koala.svsticky.nl/config/environments/production.rb

	root /var/www/koala.svsticky.nl/public;

	client_max_body_size 100M;
	keepalive_timeout 10;

	error_log /var/www/koala.svsticky.nl/log/nginx.log warn;
	access_log /var/www/koala.svsticky.nl/log/access.log;

	try_files $uri/index.html $uri @app;

	location @app {
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $http_host;
		proxy_set_header X-Forwarded-Proto https;
		proxy_redirect off;
		proxy_pass http://app;
  }

  error_page 500 502 503 504 /500.html;
}
