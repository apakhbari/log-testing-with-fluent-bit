FROM registry.eniac-tech.com/alpine:latest

RUN apk add --no-cache bash

COPY log-generator.sh /log-generator.sh
RUN chmod +x /log-generator.sh

CMD ["/log-generator.sh"]