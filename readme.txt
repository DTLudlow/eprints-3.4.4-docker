Simple EPrints 3.4 docker setup.
- Justin Bradley, July 2019

Sets up two containers, one for the database, the second for httpd and eprints.
Needs Docker and Docker Compose, if you install Docker Desktop you get both of these.

Edit docker-compose.yml and set EPRINTS_HOSTNAME to the name of your host machine, localhost is the default and fine if running locally.
Disable any services binding to port 80, ie apache httpd.
EPrints publications installation will be available via http://yourhost once set up.
User: admin
Password: admin123

# build and start
docker compose up --build -d

# normal start 
docker compose up -d

# shut down
docker compose down

# Creating a volume in Docker Compose

Under the #eprintshttpd: ... volumes:# section in docker-compose.yml, add the following entry

There are a few issues.
- The indexer often fails to start automatically.
- Some additional perl modules may be required for some import/export libraries.
