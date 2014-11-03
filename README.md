# Development 

To get a dev server going:

$ bundle install
$ rackup

To run tests:

$ bundle exec guard

# Deployment

  0. Get the wcpfs.pem file from someone who has it. Copy it to ~/.ssh/
  0. Add an entry to your ~/.ssh/config file that looks like this:

  ```
  Host scheduler
    # EC2 Host IP
    HostName scheduler.windycitypathfinder.com
    user ubuntu
    IdentityFile ~/.ssh/wcpfs.pem
  ```

  0. Run ./bin/deploy 
