FROM alpine

RUN apk update && apk add bash curl jq
ADD falco-driver-check.sh .
ENTRYPOINT [./falco-driver-check.sh]