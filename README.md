# About

Simple EPrints 3.4 docker setup.
- Justin Bradley, July 2019

Sets up two containers, one for the database, the second for httpd and eprints.
Needs Docker and Docker Compose, if you install Docker Desktop you get both of these.

# Configuration

- Edit docker-compose.yml and set EPRINTS_HOSTNAME to the name of your host machine, localhost is the default and fine if running locally.
- Disable any services binding to port 80, ie apache httpd.
- EPrints publications installation will be available via http://localhost by default (or the value specified in EPRINTS_HOSTNAME) once set up.

## Default User details
**User**: admin

**Password**: admin123

# Build and Start

1. Open a terminal window in the eprints directory
2. Run `docker compose up --build -d`

# Normal Start 

1. Open a terminal window in the eprints directory
2. Run `docker compose up -d`

# Shut Down
In a terminal pointing at the eprints directory, run `docker compose down`

# Creating a volume in Docker Compose

Under the **eprintshttpd: > volumes:** section in docker-compose.yml, add the following entry: `./shared:/usr/share/eprints/shared` This will create a folder named shared in the home/eprints directory.

Next, add `shared:` under the main **volumes:** entry in docker-compose.yml.

When you run `docker compose up -d`, the folder will appear.

# Opening the EPrints container

1. Start the container with `docker compose up -d`
2. Type `docker compose exec eprintshttpd bash` to open the container
3. Type `su eprints` to switch to the eprints user

To exit the container, type `exit` twice. The first exit logs you out of the eprints user and the second exits the container.

# Bugs

There are a few issues.
- The links on the homepage don't point to the correct directories. Plz 2 fix, mate!
- The indexer often fails to start automatically.
- Some additional perl modules may be required for some import/export libraries.
