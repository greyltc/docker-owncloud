docker-owncloud
===============

Arch Linux based Docker container including owncloud (as of this writing, version 7.0.4) running on apache with sqlite and php-xcache

## Usage
```bash
docker pull l3iggs/docker-owncloud
docker run -p 80:80 -p 443:443 -d l3iggs/docker-owncloud
```
Then point your browser to http://localhost/owncloud or https://localhost/owncloud

