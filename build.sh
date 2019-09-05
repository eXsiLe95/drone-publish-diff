#!/bin/bash

# Check if master target version is set
if [ -z "$BUILD_MASTER_TARGET_VERSION" ]; then
    echo "Master target version not set"
    exit 1
fi

# Check if slave target version is set
if [ -z "$BUILD_SLAVE_TARGET_VERSION" ]; then
    echo "Slave target version not set"
    exit 1
fi

# Get configuration file for nightly builds
wget https://update.joomla.org/core/nightlies/next_major_list.xml

# Extract Joomla! version to download
joomla_version=$(xmllint --xpath 'string(//extensionset/extension[@targetplatformversion="'$BUILD_MASTER_TARGET_VERSION'"]/@version)' next_major_list.xml)

# Download correct Joomla! nightly instance
wget https://developer.joomla.org/nightlies/Joomla_$joomla_version-Development-Full_Package.zip

# Build local Joomla! instance
git tag $BUILD_SLAVE_TARGET_VERSION
php build/build.php

# Clean up
rm next_major_list.xml
