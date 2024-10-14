SOSO Local Deployer
===================

This project contains scripts for starting and stopping SOSO frontend and
backend, along with scripts for resetting the database and changing file
permissions.

Running the Scripts
-------------------

Run the scripts by running the commands with Python:

```
python <script-name>.py
```

For example, to run the [start_services.py](./start_services.py) script, the
command is:

```
python start_services.py
```

You may need to run the scripts with superuser privileges (on Linux or Mac) if
your user doesn't have permissions to run Docker commands. For example:

```
sudo python start_services.py
```

Description of Each Script
--------------------------

### [start_services.py](./start_services.py)

Starts the frontend and backend, cloning them from GitHub if they don't exist
and starting docker containers.

### [stop_services.py](./stop_services.py)

Stops the frontend and backend by stopping their Docker containers.

### [reset_database.py](./reset_database.py)

Resets the database by clearing all tables and populating it with data.

### [change_permissions.py](./change_permissions.py)

Changes the permissions to make the user running the script to be the owner of
the frontend and backend directories. This is only important for Linux and Mac
because when the script clones the repositories from GitHub the root user may be
made owner of the directories.
