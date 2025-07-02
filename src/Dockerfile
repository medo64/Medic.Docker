FROM alpine:latest

# Time-zone
RUN apk add tzdata

# Environment
ENV ENV="/etc/profile"
RUN echo "alias ll='ls -la'" > /etc/profile.d/00-aliases.sh

# Bash
RUN apk add bash
COPY src/content/bash/default.sh /etc/bash/default.sh

# Colors
RUN apk add ncurses

# Docker
RUN apk add docker

# Done
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD []
