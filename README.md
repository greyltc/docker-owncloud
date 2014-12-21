docker-owncloud
===============

Arch Linux based Docker container including owncloud (as of this writing, version 7.0.4) running on apache with sqlite, mariadb and php-xcache

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
1. **[Optional] Setup owncloud to use mariadb instead of the default sqlite database**  
On the Owncloud initial setup page, after setting up your admin account, instead of clicking the "Finish Setup" button, you can click "Storage & database" instead. Then click the "MySQL/MariaDB" enter 'root' in the Database user field and leave the password field blank. Choose any name you like for the Database name field. The Database host filed should be left as 'localhost' if you'd like to use the mariadb server provided in this docker image.
1. **[Optional] Stop the docker-owncloud server instance**  
  ```
  docker stop oc
  ```
1. **[Optional] Delete the docker-owncloud server instance (after stopping it)**  
  ```
  docker rm oc
  ```
1. **Profit.**
