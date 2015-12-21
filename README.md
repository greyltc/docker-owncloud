docker-owncloud
===============
Simple to use Docker container with the latest ownCloud server release, complete with all the bells and whistles. This project is 100% transparent and trustable, every file in the resulting docker image is traceable and inspectable by following up the docker image depenancy tree which starts with [my Arch Linux base image](https://github.com/l3iggs/docker-archlinux).

Please report any issues or improvement ideas here:  
https://github.com/l3iggs/docker-owncloud/issues
Pull requests welcome! Let's work together!

Say thanks by adding a comment or a star here:  
https://registry.hub.docker.com/u/l3iggs/owncloud/

__Check out [the wiki](https://github.com/l3iggs/docker-owncloud/wiki)__ for some stuff that I didn't include here because I thought the readme was getting too big. Feel free to add new content to the wiki as you see fit.

### Features
- Docker tags corresponding to ownCloud releases so you won't get unexpectedly upgraded
- Uses php-xcache for the best possible performance
- Built in (optional) MySQL database server (faster than sqlite default)
  - Or specify your own pre-existing database server during setup
- Web GUI driven initial setup of user/password/database
- Based on Arch Linux ensuring __everything__ is cutting edge & up to date
- SSL (HTTPS) encryption works out-of-the-box
  - Tweaked for maximum security while maintaining compatibility 
- Optionally enable automatic SSL certificate regeneration at runtime for maximum security
  - Or easily incorporate your own SSL certificates
- In-browser document viewing and editing ready (.odt, .doc, and .docx)
- In-browser media viewing ready (pretty much everything I think)
- Comes complete with all of the official ownCloud apps pre-installed:
 - Bookmarks
 - Calendar
 - Contacts
 - Documents
 - Gallery
- Or install your own 3rd party apps

### Usage

1. [**Install docker**](https://docs.docker.com/installation/)
1. **Download and start the owncloud server instance**  

  ```
docker run --name oc -p 80:80 -p 443:443 -d l3iggs/owncloud
```
1. **Setup ownCloud**  
Point your browser to:  
http://localhost/owncloud  
or  
https://localhost/owncloud  
and follow the instructions in the web interface to finish the owncloud server setup.
1. **[Optional] Harden security**  
This image comes complete with a self-signed ssl certificate already built in, so https access is ready to go out of the box. I've provided this pre-generated certificate for convienence and testing purposes only. It affords greatly reduced security since the "private" key is not actually private; anyone can download this image and inspect the keys and then decrypt your ownCloud traffic. To make the ssl connection to this ownCloud server secure, you can (A) provide your own (secret) ssl certificate files or (B) use the script provided here to generate new, self-signed certificate files. Both will provide equal security but (B) will result in browser warnings whenever somone visits your site since the web browser will likely not trust your self-generated and self-signed keys.

  ---
_For option (A) (providing your own SSL cert files):_  
Assuming you have your own `server.crt` and `server.key` files in a directory `~/sslCert` on your host machine, then run (also on your host machine):   

  ```
sudo chown -R root ~/sslCert
sudo chgrp -R root ~/sslCert  
sudo chmod 400 ~/sslCert/server.key
```  
Then insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  

  ```
-v ~/sslCert:/https
```  

  ---
_For option (B) (using the built-in script to re-generate your own self-sigend ssl certificate):_  
  - The image includes a bash script (`/etc/httpd/conf/genSSLKey.sh`) that generates new ssl cert files on command (and overwrites the public ones included in this image). You can use this script to regenerate a new SSL key anytime on the fly. you only need to restart the apache server after regenerating your keys. After starting the docker image as described above, run the following commands:  
  ```
docker exec -it oc sh -c 'SUBJECT="/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost" /etc/httpd/conf/genSSLKey.sh'  
docker exec -it oc apachectl restart #<-- note that this will terminate ongoing connections
```
  - To have a new ssl certificate generated automatically _every time_ the image is started, insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
  ```
-e REGENERATE_SSL_CERT=true -e SUBJECT=/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost
```
The `SUBJECT` variable is actually optional here, but I put it in there to show how to change the generated certificate to your liking, especially important if you don't want your certificate to be for `localhost`  
For either (A) or (B)~~, remember to turn on the option to force https connections in the ownCloud admin settings page to take advantage of your hardened security~~ UPDATE: starting in version 8.1, the OwnCloud devs have decided to remove this useful feature from their software by accepting the following PR: https://github.com/owncloud/core/pull/14651 which removes the "Enforce HTTPS" tickbox from the settings page.
1. **[Optional] Stop the docker-owncloud server instance**

  ```
docker stop oc
```
You can restart the container later with `docker start oc`
1. **[Optional] Delete the docker-owncloud server instance (after stopping it)**  

  ```
docker rm oc #<--WARNING: this will delete anything stored inside the container
```
1. **Profit.**

### Updating to the latest container

NOTE: Docker 1.7 is scheduled for release on 06/16/2015. This will bring with it named containers which will greatly simplify & improve container data management. Stay tuned for a new upgrade strategy.

From time-to-time I'll update the continer to add new features or fix bugs or update to a new ownCloud server release, so you might want to update the ownCloud container you're using.
- Run `docker pull l3iggs/owncloud`
- If the above command returns "Status: Image is up to date" then you've got the latest image and you're done. Otherwise:
  - Run `docker stop oc` <-- warning: this will immediately stop your server
  - Then run `docker rm oc` <-- WARNING: this may cause catastrophic data loss. It WILL delete anything stored inside the container. If you wish to retain important things like data files and configuration files after running this command, then see the wiki on Github for instructions on how to store these things outside of the container.
- Now start the new container again like normal.
