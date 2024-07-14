#!/bin/bash

# Configuration
OMBI_TEMP="/home/USER/ombi" # Temporary Path Where OMBI Will Be Extracted
CURRENT_OMBI_PATH="/opt/ombi"  # Path Where OMBI is Currently Installed
LATEST_OMBI_BACKUP_PATH="/opt/ombi-backup"  # Path Where the Latest OMBI Backup Will Be Stored
OLDEST_OMBI_BACKUP_PATH="/opt/ombi-backup-old"  # Path Where the Oldest OMBI Backup Will Be Stored
#OMBI_DATABASE_FILE="/opt/ombi-backup/Ombi.db"  # File Containing OMBI Database *Uncomment if Using SQLite & Add Variable to "Copies the Database Backups...." Section
#OMBI_SETTINGS_DATABASE_FILE="/opt/ombi-backup/OmbiSettings.db"  # File Containing OMBI Settings Database *Uncomment if Using SQLite & Add Variable to "Copies the Database Backups...." Section
#OMBI_EXTERNAL_SETTINGS_DATABASE_FILE="/opt/ombi-backup/OmbiExternal.db"  # File Containing OMBI External Settings Database *Uncomment if Using SQLite & Add Variable to "Copies the Database Backups...." Section
OMBI_MYSQL_DATABASE_FILE="/opt/ombi-backup/database.json"  # File Containing OMBI MySQL Database Connection Info *Uncomment if using MySQL & Add Variable to "Copies the Database Backups...." Section
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="/opt/Logs/ombi_update_log_$TIMESTAMP.txt"

# Log Message Function
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Stops OMBI Service
log_message "Stopping OMBI Service..."
if sudo systemctl stop ombi; then
    log_message "OMBI Service Successfully Stopped!"
else
    log_message "Stopping OMBI Service Failed!"
    exit 1
fi

# Deletes Oldest OMBI Backup Files
log_message "Deleting Oldest OMBI Backup Files..."
if sudo rm -rf "$OLDEST_OMBI_BACKUP_PATH"; then
    log_message "Deleted Oldest OMBI Backup Successful: $OLDEST_OMBI_BACKUP_PATH"
else
    log_message "Deletion of Oldest OMBI Backup Failed!"
    exit 1
fi

# Backs Up Latest OMBI Backup Files
log_message "Backing up Latest OMBI Backup Files..."
sudo mkdir -p "$OLDEST_OMBI_BACKUP_PATH"
if sudo cp -r "$LATEST_OMBI_BACKUP_PATH/." "$OLDEST_OMBI_BACKUP_PATH"; then
    log_message "Backup of Latest OMBI Backup Successful: $LATEST_OMBI_BACKUP_PATH to $OLDEST_OMBI_BACKUP_PATH"
else
    log_message "Backup of Latest OMBI Backup Failed!"
    exit 1
fi

# Deletes Latest OMBI Backup Files
log_message "Deleting Latest OMBI Backup Files..."
if sudo rm -rf "$LATEST_OMBI_BACKUP_PATH"; then
    log_message "Deleted Latest OMBI Backup Successful: $LATEST_OMBI_BACKUP_PATH"
else
    log_message "Deletion of Latest OMBI Backup Failed!"
    exit 1
fi

# Backs Up Current OMBI Files
log_message "Backing up Current OMBI Files..."
sudo mkdir -p "$LATEST_OMBI_BACKUP_PATH"
if sudo cp -r "$CURRENT_OMBI_PATH/." "$LATEST_OMBI_BACKUP_PATH"; then
    log_message "Backup of Current OMBI Successful: $CURRENT_OMBI_PATH to $LATEST_OMBI_BACKUP_PATH"
else
    log_message "Backup of Current OMBI Backup Failed!"
    exit 1
fi

# Downloads User Specified Version of OMBI
read -p "What version of OMBI would you like to install? " version
log_message "Downloading OMBI Version $version..."
if wget -q https://github.com/Ombi-app/Ombi/releases/download/v$version/linux-x64.tar.gz; then
    log_message "OMBI Version $version Successfully Downloaded!"
else
    log_message "Download Failed!"
    exit 1
fi

# Create Temp OMBI Folder
log_message "Creating Temporary OMBI Directory..."
if sudo mkdir "$OMBI_TEMP"; then
    log_message "Creation of Temporary OMBI Directory Successful: $OMBI_TEMP"
else
    log_message "Creation of Temporary OMBI Directory Failed!"
    exit 1
fi

# Extracts Archive
log_message "Extracting OMBI Archive..."
if sudo tar -xzf linux-x64.tar.gz --directory $OMBI_TEMP; then
    log_message "Extraction of OMBI Archive Successful!"
else
    log_message "Extraction of OMBI Archive Failed!"
    exit 1
fi

# Deletes Archive
log_message "Deleting OMBI Archive..."
if sudo rm linux-x64.tar.gz; then
    log_message "Deletion of OMBI Archive Successful!"
else
    log_message "Deletion of OMBI Archive Failed!"
    exit 1
fi

# Deletes Current OMBI Files
log_message "Deleting Latest OMBI Backup Files..."
if sudo rm -rf "$CURRENT_OMBI_PATH"; then
    log_message "Deletion of Current OMBI Files Successful: $CURRENT_OMBI_PATH"
else
    log_message "Deletion of Current OMBI Files Failed!"
    exit 1
fi

# Moves Temp OMBI to Working Location
log_message "Move Temporary OMBI Folder to Working Location..."
if sudo mv "$OMBI_TEMP" "$CURRENT_OMBI_PATH"; then
    log_message "OMBI Moved from Temporary Location to Working Location: $OMBI_TEMP to $CURRENT_OMBI_PATH"
else
    log_message "Directory Move Failed!"
    exit 1
fi

# Copies the Database Backups from Current OMBI Backup to Current OMBI (Must Add/Remove Variables from Configuration if Using SQLite/MySQL)
log_message "Restoring Database Backups..."
if sudo cp "$OMBI_MYSQL_DATABASE_FILE" "$CURRENT_OMBI_PATH/"; then
    log_message "Restoration of Database Files Successful!"
else
    log_message "Restoration of Database Files Failed!"
    exit 1
fi

# Change Ownership of Current OMBI
log_message "Changing Ownership of Current OMBI Files..."
if sudo chown brad:brad -R $CURRENT_OMBI_PATH; then
    log_message "Ownership Change Successful!"
else
    log_message "Ownership Change Failed!"
    exit 1
fi

# Reloads Daemon
log_message "Reloading Daemon..."
if sudo systemctl daemon-reload; then
    log_message "Daemon Successfully Reloaded!"
else
    log_message "Daemon Reloading Failed!"
    exit 1
fi

# Restarts OMBI Service
log_message "Restarting OMBI Service..."
if sudo systemctl restart ombi; then
    log_message "OMBI Service Successfully Restarted!"
else
    log_message "Starting OMBI Service Failed!"
    exit 1
fi

# Displays Status of OMBI Service
sudo systemctl status ombi

log_message "OMBI Updated to Version $version Successfully!"


