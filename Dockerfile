FROM alpine:edge
RUN apk --no-cache add \
        libressl \
        lftp \
        bash
ADD script.sh /bin/
RUN chmod +x /bin/script.sh

ENTRYPOINT /bin/script.sh

