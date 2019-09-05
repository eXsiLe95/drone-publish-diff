FROM alpine:edge
RUN apk --no-cache add \
        libressl \
        lftp \
        bash
ADD compare.sh /bin/
ADD upload.sh /bin/

