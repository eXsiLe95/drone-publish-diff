#!/bin/bash

# Check if FTP username is set
if [ -z "$FTP_USERNAME" ]; then
    echo "FTP-username not set"
    exit 1
fi

# Check if FTP hostname is set
if [ -z "$FTP_HOSTNAME" ]; then
    echo "FTP-hostname not set"
    exit 1
fi

# Check if FTP password is set
if [ -z "$FTP_PASSWORD" ]; then
    echo "FTP-password not set"
    exit 1
fi

# Allow and enforce SSL decryption
if [ -z "$FTP_SECURE" ]; then
    FTP_SECURE="true"
fi

# Verify certificate and check hostname
if [ -z "$FTP_VERIFY" ]; then
    FTP_VERIFY="true"
fi

# Destination directory on remote server
if [ -z "$FTP_DEST_DIR" ]; then
    FTP_DEST_DIR="/"
fi

# Source directory on local machine
if [ -z "$FTP_SRC_DIR" ]; then
    FTP_SRC_DIR="/"
fi

# Disallow file permissions
if [ "$FTP_CHMOD" = false ]; then
    FTP_CHMOD="-p"
else
    FTP_CHMOD=""
fi

# Clean remote directory before deploy
if [ "$FTP_CLEAN_DIR" = true ]; then
    FTP_CLEAN_DIR="rm -r $FTP_DEST_DIR"
else
    FTP_CLEAN_DIR=""
fi

FTP_EXCLUDE_STRING=""
FTP_INCLUDE_STRING=""

IFS=',' read -ra in_arr <<< "$FTP_EXCLUDE"
for i in "${in_arr[@]}"; do
    FTP_EXCLUDE_STRING="$FTP_EXCLUDE_STRING -x $i"
done
IFS=',' read -ra in_arr <<< "$FTP_INCLUDE"
for i in "${in_arr[@]}"; do
    FTP_INCLUDE_STRING="$FTP_INCLUDE_STRING -x $i"
done

echo "Opening lftp connection with parameters:"
echo "FTP Username: " $FTP_USERNAME
echo "FTP Password: " $FTP_PASSWORD
echo "FTP Hostname: " $FTP_HOSTNAME

lftp -e "set xfer:log 1; \
    set ftp:ssl-allow $FTP_SECURE; \
    set ftp:ssl-force $FTP_SECURE; \
    set ftp:ssl-protect-data $FTP_SECURE; \
    set ssl:verify-certificate $FTP_VERIFY; \
    set ssl:check-hostname $FTP_VERIFY; \
    $FTP_CLEAN_DIR; \
    mirror --verbose $FTP_CHMOD -R $FTP_INCLUDE_STRING $FTP_EXCLUDE_STRING '$(pwd)'$FTP_SRC_DIR $FTP_DEST_DIR" \
    -u $FTP_USERNAME,$FTP_PASSWORD $FTP_HOSTNAME

