# Development 

To get a dev server going, first get the .env file from someone who as it. Then run these commands:

  ```
  $ source .env
  $ bundle install
  $ rackup
  ```
Go to localhost:9292 to see the app

### To run Ruby tests

  ```
  $ bundle exec guard
  ```

### To run JavaScript tests
  * Start the server and go to localhost:9292/tests to run the tests. 
  * You can use the http://tin.cr/ plugin to run them automatically.

# Deployment

  0. Get the wcpfs.pem file from someone who has it. Copy it to ~/.ssh/
  0. Add an entry to your ~/.ssh/config file that looks like this:

  ```
  Host beta.windycitypathfinder.com
    # EC2 Host IP
    HostName beta.windycitypathfinder.com
    user ubuntu
    IdentityFile ~/.ssh/wcpfs.pem
  ```

  0. Run ./bin/deploy 
