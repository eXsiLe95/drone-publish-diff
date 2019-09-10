FROM alpine:edge
RUN apk --no-cache add \
        libressl \
        lftp \
        bash \
        diffutils \
        git \
        openssh-client \
        zip
ADD compare.sh .
RUN chmod +x ./compare.sh

# ENV CMP_ARCHIVE="build"
# ENV CMP_MASTER_FOLDER="./reference"
# ENV CMP_SLAVE_FOLDER="/home/lum4x/Documents/THM/Studium/WPW/joomla4"

# ENV FTP_USERNAME="joomla"
# ENV FTP_HOSTNAME="joomla-dev.lukaskimpel.com:21"
# ENV FTP_PASSWORD="Jpwd123!"
# ENV FTP_VERIFY="false"
# ENV FTP_SECURE="false"
# ENV FTP_DEST_DIR="patchtester/"

# ENV BRANCH_NAME="4.0-dev"
# ENV DRONE_PULL_REQUEST="12345"

ENTRYPOINT ./compare.sh
