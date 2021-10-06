FROM alpine:3.10

RUN apk --update add curl

# Download kubectl binary
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

RUN chmod +x kubectl

RUN mv kubectl /bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
