FROM registry.eniac-tech.com/alpine:latest

# Install bash (required by your shebang #!/bin/bash) and dos2unix
RUN apk update && \
    apk add --no-cache bash dos2unix && \
    rm -rf /var/cache/apk/*

# Copy the script into the image
COPY log-generator.sh /log-generator.sh

# 🔑 CRITICAL FIX: Convert CRLF line endings to LF line endings
RUN dos2unix /log-generator.sh

# Ensure the script is executable (already done, but good to keep)
RUN chmod +x /log-generator.sh

# Set the container's entry command
CMD ["/log-generator.sh"]