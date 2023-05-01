# EPrints 3.4.4 Docker Image

A modified version of the original by Justin Bradley, with the following improvements:

- No unmet dependencies
- Uses latest version of EPrints (v3.4.4)
- Includes a directory for ease of moving files to and from the container  (`/var/shared` directory within the container)

### To Do

- Switch base image from Centos to AlmaLinux

## Built-in User Details

**User**: admin

**Password**: admin123

## Building the Repository

1. Copy the contents of this repository into /home/eprints
2. cd into /home/eprints
3. Build the Docker container by typing `docker compose up --build -d` in a terminal. This will take a little time to complete, as Docker is creating the volumes and acquiring everything EPrints needs to run.

## Completing setup

In order to ensure that EPrints is set up correctly:

1. Ensure that the terminal prompt is in the eprints folder
2. Open the Docker container in the terminal: `docker compose exec eprintshttpd bash​​​​​​​`
3. Run `chown -R -c eprints.eprints /usr/share/eprints/` to ensure that the eprints user owns all files in the eprints directory
4. Switch to the eprints user with: `su eprints`
5. Run `/usr/share/eprints/bin/generate_static pub` to ensure that there are no broken links on the homepage
6. Run `/usr/share/eprints/bin/epadmin update pub` to ensure the admin user is added to the database
7. Run `/usr/share/eprints/bin/epadmin reload pub` to reload the archive's configuration
8. Type `exit` to switch back to the root user
9. Run `httpd -k restart` to restart the web server

## Starting the session

1. Check that Docker is running okay with `service docker status`
2. Navigate to the folder that eprints is installed in (home/eprints)
3. Run eprints with `docker compose up -d`
4. Open a browser window and go to http://localhost to see the front-end interface​​​​​​​

## Ending the session

1. Close connection to the Docker container by typing `exit` twice (first is to logout the eprints user, second is to logout the root user)
2. Quit the EPrints app with `docker compose down`
