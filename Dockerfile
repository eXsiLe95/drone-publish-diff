FROM alpine:edge
RUN apk --no-cache add \
        libressl \
        lftp \
        bash
ADD build.sh /bin/
ADD compare.sh /bin/
ADD upload.sh /bin/

