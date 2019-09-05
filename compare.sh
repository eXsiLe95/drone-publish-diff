#!/bin/bash

# Check if master file is set
if [ -z "$CMP_MASTER_FILE" ]; then
    echo "Master file not set"
    exit 1
fi

# Check if slave file is set
if [ -z "$CMP_SLAVE_FILE" ]; then
    echo "Slave file not set"
    exit 1
fi

# Check if archive name is set
if [ -z "$CMP_ARCHIVE" ]; then
    echo "Archive name not set"
    exit 1
fi

# Create directories
CMP_TMP="tmp"
CMP_MASTER_DIR="tmp/master"
CMP_SLAVE_DIR="tmp/slave"
CMP_BUILD_DIR="tmp/build"
CMP_DIFF_LOG="tmp/diff.log"
CMP_ONLY_IN_MASTER_LOG="tmp/only_in_master.log"
CMP_ONLY_IN_SLAVE_LOG="tmp/only_in_slave.log"
CMP_DIFFERS_FROM_LOG="tmp/differs_from.log"
mkdir $CMP_TMP
mkdir $CMP_MASTER_DIR
mkdir $CMP_SLAVE_DIR

# Unzip archives to compare them
unzip $CMP_MASTER_FILE -d $CMP_MASTER_DIR
unzip $CMP_SLAVE_FILE -d $CMP_SLAVE_DIR

# Compare files/directories
diff -qr $CMP_MASTER_DIR $CMP_SLAVE_DIR >> $CMP_DIFF_LOG

# Create list of files that only exist in master directory
cat $CMP_DIFF_LOG | grep -E "^Only in "$CMP_MASTER_DIR"*" | sed -n 's/://p' | awk '{print $3"/"$4}' >> $CMP_ONLY_IN_MASTER_LOG

# Create list of files that only exist in slave directory
cat $CMP_DIFF_LOG | grep -E "^Only in "$CMP_SLAVE_DIR"*" | sed -n 's/://p' | awk '{print $3"/"$4}' >> $CMP_ONLY_IN_SLAVE_LOG

# Create list of files that differ from master
cat $CMP_DIFF_LOG | grep -Eo " and tmp\/slave\/[^[:space:]]+" | grep -Eo "tmp\/slave\/[^[:space:]]+" >> $CMP_DIFFERS_FROM_LOG

# Create build folder
mkdir $CMP_BUILD_DIR

# Copy all files that only occur in master into build folder
while IFS="" read -r file || [ -n "$file" ]
do
    destination_file="$CMP_BUILD_DIR/$(echo $file  | cut -d'/' -f3-)"
    mkdir -p $destination_file && cp -r $file $destination_file
done < $CMP_ONLY_IN_MASTER_LOG

# Copy all files that only occur in slave into build folder
while IFS="" read -r file || [ -n "$file" ]
do
    destination_file="$CMP_BUILD_DIR/$(echo $file  | cut -d'/' -f3-)"
    mkdir -p $destination_file && cp -r $file $destination_file
done < $CMP_ONLY_IN_SLAVE_LOG

# Copy all files that differ into build folder
while IFS="" read -r file || [ -n "$file" ]
do
    destination_file="$CMP_BUILD_DIR/$(echo $file  | cut -d'/' -f3-)"
    mkdir -p $destination_file && cp -r $file $destination_file
done < $CMP_DIFFERS_FROM_LOG

# Zip build folder
zip -qr $CMP_ARCHIVE $CMP_BUILD_DIR

# Clean up temporary files
# rm -rf $CMP_TMP
