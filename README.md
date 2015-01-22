docker-owncloud
===============

Arch Linux based Docker container including owncloud (as of this writing, version 7.0.4) running on apache with sqlite, mariadb and php-xcache.

## Usage

1. [**Install docker**](https://docs.docker.com/installation/)
1. **Download and start the owncloud server instance**  
  ```
  docker run --name oc -p 80:80 -p 443:443 -d l3iggs/docker-owncloud
  ```
1. **Access the docker setup page**  
Point your browser to:  
http://localhost/owncloud  
or  
https://localhost/owncloud  
1. **Setup your owncloud admin account**  
Enter your desired username and password in the fields shown and click the "Finish Setup" button.
1. **[Optional] Change your owncloud data storage location**  
On the Owncloud initial setup page, after setting up your admin account, instead of clicking the "Finish Setup" button, you can click "Storage & database" instead. You can change the data folder location here (note that this is a path inside the docker container, not on your host machine).  
It's likely desirable for owncloud's data storage to be placed in a persistant storage location outside the docker container, on the host's file system for example. Let's imagine you wish to store your docker files in a folder `~/ocfiles` on the host's file system. Then insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
```-v ~/ocfiles:/usr/share/webapps/owncloud/data```  
UID 33 or GID 33 (http in the container image) must have r/w permissions for `~/ocfiles` on the host system. Generally, it's enough to do:  
```chmod -R 770  ~/ocfiles; sudo chgrp -R 33  ~/ocfiles```  
[Read this if you run into permissions issues in the container.](http://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker)
1. **[Optional] Change your owncloud config storage location**  
Similar to the above change, this allows the owncloud config directory to be stored outside of the docker container.  
```-v ~/occonfig:/etc/webapps/owncloud/config```  
```chmod -R g+rw  ~/occonfig; sudo chgrp -R 33  ~/occonfig```
1. **[Optional] Setup owncloud to use mariadb instead of the default sqlite database**  
On the Owncloud initial setup page, after setting up your admin account, instead of clicking the "Finish Setup" button, you can click "Storage & database" instead. Then click the "MySQL/MariaDB" enter 'root' in the Database user field and leave the password field blank. Choose any name you like for the Database name field. The Database host filed should be left as 'localhost' if you'd like to use the mariadb server provided in this docker image.
1. **[Optional] Use your own ssl certificate**  
Assuming you have `server.crt` and `server.key` files in a directory `~/sslCert`:   
```chown -R root ~/sslCert; chgrp -R root ~/sslCert```  
```chmod 400 ~/sslCert/server.key```   
You can then add `-v ~/sslCert:/https` to the docker run command line to use your ssl certificate files.  
1. **[Optional] Stop the docker-owncloud server instance**  
  ```
  docker stop oc
  ```
1. **[Optional] Delete the docker-owncloud server instance (after stopping it)**  
  ```
  docker rm oc
  ```
1. **Profit.**
