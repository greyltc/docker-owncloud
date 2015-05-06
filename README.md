docker-owncloud
===============

Arch Linux based Docker container including ownCloud via apache with speedups provided by php-xcache and built-in mysql and sqlite database support.

Please report any issues or improvement ideas here:  
https://github.com/l3iggs/docker-owncloud/issues

Say thanks by adding a comment or a star here:  
https://registry.hub.docker.com/u/l3iggs/owncloud/

The following official ownCloud apps come pre-installed here:
- Bookmarks
- Calendar
- Contacts
- Documents
- Gallery

__Check out [the wiki](https://github.com/l3iggs/docker-owncloud/wiki)__ for some stuff that I didn't include in this readme because I think it's getting too big.

## Usage

1. [**Install docker**](https://docs.docker.com/installation/)
1. **Download and start the owncloud server instance**  
`docker run --name oc -p 80:80 -p 443:443 -d l3iggs/owncloud`
1. **Setup ownCloud**  
Point your browser to:  
http://localhost/owncloud  
or  
https://localhost/owncloud  
and follow the on-onscreen instructions to finish the owncloud server setup.
1. **[Optional] Harden security**  
This image comes complete with a self-signed ssl certificate already built in, so https access is ready to go out of the box. I've provided this pre-generated certificate for convienence and testing purposes only. It affords greatly reduced security since the "private" key is not actually private; anyone can download this image and inspect the keys and then decrypt your ownCloud traffic. To make the ssl connection to this ownCloud server secure, you can (A) provide your own (secret) ssl certificate files or (B) use the script provided here to generate new, self-signed certificate files. Both will provide equal security but (B) will result in browser warnings whenever somone visits your site since the web browser will likely not trust your self-signed keys.  
_For option (A) (providing your own SSL cert files):_  
Assuming you have your own `server.crt` and `server.key` files in a directory `~/sslCert` on the host machine run:   
`sudo chown -R root ~/sslCert; sudo chgrp -R root ~/sslCert`  
`sudo chmod 400 ~/sslCert/server.key`   
Then insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
`-v ~/sslCert:/https`  
_For option (B) (using the built-in script to re-generate your own self-sigend ssl certificate):_  
Any time after starting the docker image as described above, run the following two commands:  
`docker exec -it oc sh -c 'SUBJECT="/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost" /etc/httpd/conf/genSSLKey.sh'`  
`docker exec -it oc apachectl restart` <-- note that this will terminate ongoing connections  
To have a new ssl certificate generated automatically every time the image is started, insert the following into the docker startup command (from step 2. above) between `run` and `--name`:  
`-e REGENERATE_SSL_CERT=true -e SUBJECT=/C=US/ST=CA/L=CITY/O=ORGANIZATION/OU=UNIT/CN=localhost`  
You can edit the `SUBJECT` of the certificate to your liking, especially important if you don't want your certificate to be for `localhost`  
For either (A) or (B), remember to turn on the option to force https connections in the ownCloud admin settings page to take advantage of your hardened security.
1. **[Optional] Stop the docker-owncloud server instance**  
`docker stop oc`
1. **[Optional] Delete the docker-owncloud server instance (after stopping it)**  
`docker rm oc`
1. **Profit.**
