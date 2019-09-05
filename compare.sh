#!/bin/bash

# Check if master file is set
if [ -z "$CMP_MASTER_FOLDER" ]; then
    echo "Master folder hasn't been set"
    exit 1
fi

# Check if slave file is set
if [ -z "$CMP_SLAVE_FOLDER" ]; then
    echo "Slave folder hasn't been set"
    exit 1
fi

# Check if archive name is set
if [ -z "$CMP_ARCHIVE" ]; then
    echo "Build Archive name hasn't been set"
    exit 1
fi



# Declare temp directories
CMP_TMP="tmp"
CMP_MASTER_DIR="$CMP_TMP/master"
CMP_SLAVE_DIR="$CMP_TMP/slave"
CMP_BUILD_DIR="$CMP_TMP/build"
CMP_DIFF_LOG="$CMP_TMP/diff.log"
CMP_ONLY_IN_MASTER_LOG="$CMP_TMP/only_in_master.log"
CMP_ONLY_IN_SLAVE_LOG="$CMP_TMP/only_in_slave.log"
CMP_DIFFERS_FROM_LOG="$CMP_TMP/differs_from.log"

# Remove existent temp directory
rm -rf $CMP_TMP

# Create temp directories
mkdir $CMP_TMP
mkdir $CMP_MASTER_DIR
mkdir $CMP_SLAVE_DIR

# Compare files/directories
echo "Finding differences between builds..."
	diff --exclude=node_modules \
             --exclude=build \
             --exclude=administrator/components/com_media/node_modules \
        $CMP_MASTER_FOLDER $CMP_SLAVE_FOLDER >> $CMP_DIFF_LOG

# Create list of files that only exist in master directory
cat $CMP_DIFF_LOG | grep -E "^Only in "$CMP_MASTER_FOLDER"*" | sed -n 's/\/://p' |  awk '{print $3"/"$4}' >> $CMP_ONLY_IN_MASTER_LOG

# Create list of files that only exist in slave directory
cat $CMP_DIFF_LOG | grep -E "^Only in "$CMP_SLAVE_FOLDER"*" | sed -n 's/\/://p' | awk '{print $3"/"$4}' >> $CMP_ONLY_IN_SLAVE_LOG

# Create list of files that differ from master
cat $CMP_DIFF_LOG | grep -Eo " and tmp\/slave\/[^[:space:]]+" | grep -Eo "tmp\/slave\/[^[:space:]]+" >> $CMP_DIFFERS_FROM_LOG

echo "Finished finding differences between builds."

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
echo "Zipping build folder..."
zip -qr $CMP_ARCHIVE $CMP_BUILD_DIR
echo "Finished zipping build."

# Clean up temporary files
# rm -rf $CMP_TMP
