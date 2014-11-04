# Dev Environment

  * Run ./bin/server to start a local webserver
  * Go to localhost:8000 to see the app
  * Go to localhost:8000/tests to run the tests. You can use the http://tin.cr/ plugin to run them automatically.

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
