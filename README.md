# Development 

To get a dev server going:

$ bundle install
$ rackup

To run tests:

$ bundle exec guard

# Deployment

  0. Get the aws.pem file from someone who has it. Copy it to ~/.ssh/
  0. Add an entry to your ~/.ssh/config file that looks like this:

  Host scheduler
    # EC2 Host IP
    HostName 54.225.255.234
    user ubuntu
    IdentityFile ~/.ssh/aws.pem

  0. Run ./bin/deploy 

# Nginx

We use nginx to front this app with a reverse proxy. Here's the configuration, which should be placed in /etc/nginx/sites-enabled

```
server {
        listen   80;
        server_name  www.windycitypathfinder.com;

        access_log  /var/log/nginx/access.log;


        location / {
                proxy_pass      http://127.0.0.1:8080/;
		proxy_redirect          off;
		proxy_set_header        Host            $host;
		proxy_set_header        X-Real-IP       $remote_addr;
		proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
```
