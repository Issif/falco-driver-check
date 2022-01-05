FROM alpine

RUN apk update && apk add bash curl jq
COPY falco-driver-check.sh .
RUN chmod +x falco-driver-check.sh
ENTRYPOINT ["/bin/bash", "falco-driver-check.sh"]