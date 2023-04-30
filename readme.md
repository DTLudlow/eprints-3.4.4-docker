# EPrints 3.4.4 Docker Image

## Note: Need to fix a few things first!!!

A modified version of the original by Justin Bradley, with the following improvements:

- No unmet dependencies
- Uses latest version of EPrints (v3.4.4)
- Includes a directory for ease of moving files to and from the container  (`/var/shared` directory within the container)

## Built-in User Details

**User**: admin

**Password**: admin123

## Building the Repository

1. Open Ubuntu via the Remote Explorer extension in Visual Studio Code
2. cd into /home/eprints
3. Build the Docker container by typing `docker compose up --build -d`. This will take a little time to complete, as Docker is creating the volumes and acquiring everything EPrints needs to run.

## Completing setup

In order to ensure that EPrints is set up correctly:

1. Ensure that the terminal prompt is in the eprints folder
2. Open the Docker container in the terminal: `docker compose exec eprintshttpd bash​​​​​​​`
3. Run `chown -R -c eprints.eprints /usr/share/eprints/lib/cfg.d` to ensure that the eprints user can run the perl configuration scripts
4. Run `chown -R -c eprints.eprints /usr/share/eprints/bin/` to allow the eprints user to run the update scripts
5. Switch to the eprints user with: `su eprints`
6. Run `/usr/share/eprints/bin/generate_static pub` to fix the broken links on the homepage
7. Run `/usr/share/eprints/bin/epadmin update pub` to ensure the default user is added to the database
8. Run `/usr/share/eprints/bin/epadmin reload pub` to reload the archive's configuration
9. Type `exit` to switch back to the root user
10. Run `httpd -k restart` to restart the web server

## Starting the session

1. Start the Docker service with `sudo service docker start`
2. Check that Docker is running okay with `service docker status`
3. Navigate to the folder that eprints is installed in (home/eprints)
4. Run eprints with `docker compose up -d`
5. Open a browser window and go to http://localhost to see the front-end interface​​​​​​​

## Ending the session

1. Close connection to the Docker container by typing `exit` twice (first is to logout the eprints user, second is to logout the root user)
2. Quit the EPrints app with `docker compose down`
3. (Optional): Shut off the Docker service with `sudo service docker stop`