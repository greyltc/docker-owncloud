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
- Streamlined [Let's Encrypt](https://letsencrypt.org/) functionality built right in
  - This will fetch valid, trusted and free SSL certs for your domain and install them into the image!
  - Horray for green lock icons!
- __Superfast__
  - Uses PHP7 with APCu and Zend OpCache for maximum performance
- Now with image version tags corresponding to OwnCloud release versions
  - So you won't get unexpectedly upgraded and you can safely stay on an OC version you know is working for you
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
~~http://localhost/owncloud~~ (I've decided to disable visiting the owncloud server without encryption)  
~~or~~  
https://localhost/owncloud  
and follow the instructions in the web interface to finish the owncloud server setup.
1. **[Optional] Harden security**  
This image comes complete with a self-signed ssl certificate already built in, so https access is ready to go out of the box. I've provided this pre-generated certificate for convienence and testing purposes only. It affords greatly reduced security (compared to using secret certificates) since the "private" key is not actually private; anyone can download this image and inspect the keys and then decrypt your ownCloud traffic (sniffing your login credentials for example). To make the ssl connection to this ownCloud server secure, you can:  
(A) provide your own (secret) ssl certificate files  
(B) use the script provided here to generate new, self-signed certificate files  
or  
(C) use the script provided here to fetch (free) certificates for your domain from the [Let's Encrypt project](https://letsencrypt.org/)  
All of these will provide equal security (since the encryption key will be kept secret) but (B) will result in browser warnings whenever somone visits your site since the web browser will likely not trust your self-generated and self-signed keys.

  ---
_For option (A) (providing your own SSL cert files):_  
  Put your `server.crt` and `server.key` files (named exactly that) in a directory `~/sslCert` on your host machine, then run (also on your host machine):   

  ```
sudo chown -R root ~/sslCert
sudo chgrp -R root ~/sslCert  
sudo chmod 400 ~/sslCert/server.key
```  
 Then insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  

  ```
-v ~/sslCert:/root/sslKeys
```  

  ---
_For option (B) (using the built-in script to re-generate your own self-sigend ssl certificate):_  
  - The image includes a bash script (`/usr/sbin/setup-apache-ssl-key`) that generates new ssl cert files on command (and overwrites the pregenerated ones included in this image). You can use this script to regenerate a new SSL key anytime, on the fly. After starting the docker image as described above, run the following command:  
  ```
docker exec -it oc sh -c 'SUBJECT="/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost" DO_SSL_SELF_GENERATION=true setup-apache-ssl-key'  
```
  - To have a new ssl certificate generated automatically _every time_ the image is started, insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
  ```
-e DO_SSL_SELF_GENERATION=true -e SUBJECT=/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost
```
  The `SUBJECT` variable is actually optional here, but I put it in there to show how to change the generated certificate to your liking, especially important if you don't want your certificate to be for `localhost`  

  ---
_For option (C) (fetching a free, trusted cert from letsencrypt.org):_  
  For this to work, __this container must be reachable from the internet by visiting http://your.domain.tld__ (where "your.domain.tld" will obviously be unique to you). In fact, a Let's Encrypt robot will attempt to visit this address via port 80 to read files served up by the apache server in this container during the certificate fetching process to verify your ownership of the domain.  
  After starting the docker image as described above, run the following command (substituting your proper email address and domain name):  
  ```
docker exec -it oc sh -c 'EMAIL=youremail@addre.ss HOSTNAME=your.domain.tld DO_SSL_LETS_ENCRYPT_FETCH=true setup-apache-ssl-key'  
```
  ~30 seconds later you should get a green lock in your browser when visiting your OC server at https://your.domain.tld/owncloud  
  Now save your newly fetched certificate files somewhere safe:
  ```
docker cp oc:/etc/letsencrypt/live/your.domain.tld ~/letsencryptFor_your.domain.tld
```
  and next time you use docker to start your OC server container, use option (A) to feed your `.key` and `.crt` files into the image when it starts.  
  __NOTE:__ Let's Encrypt gives you a certificate that's valid for three months, afterwhich it needs to be renewed if you'd like to continue getting green locks in your browser. If you run the above `DO_SSL_LETS_ENCRYPT_FETCH=true setup-apache-ssl-key` command, and then you leave your server running without restarting for three months or longer, your certificate *should* be auto-renewed forever. If you restart the container, you'll probably need to re-issue the `DO_SSL_LETS_ENCRYPT_FETCH=true setup-apache-ssl-key` command again manually if you don't want your certificate to expire three months after you first fetched it.  
  __NOTE #2:__ Let's Encrypt has a strict rate limiting policy; it will only grant 5 certificates / 7 days / domain so be very careful with how often you issue the `DO_SSL_LETS_ENCRYPT_FETCH=true setup-apache-ssl-key` command above

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

From time-to-time I'll update the continer to add new features or fix bugs or update to a new ownCloud server release, so you might want to update the ownCloud container you're using.
- Run `docker pull l3iggs/owncloud`
- If the above command returns "Status: Image is up to date" then you've got the latest image and you're done. Otherwise:
  - Run `docker stop oc` <-- warning: this will immediately stop your server
  - Then run `docker rm oc` <-- WARNING: this may cause catastrophic data loss. It WILL delete anything stored inside the container. If you wish to retain important things like data files and configuration files after running this command, then see the wiki on Github for instructions on how to store these things outside of the container.
- Now start the new container again like normal.
