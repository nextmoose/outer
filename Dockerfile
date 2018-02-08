FROM docker:18.01.0-ce
RUN \
    apk add --no-cache coreutils &&
        apk add --no-cache util-linux &&
        adduser -D user && \
        echo "user ALL=(ALL) NOPASSWD:SETENV: /usr/bin/docker" > /etc/sudoers.d/user && \
        chmod 0444 /etc/sudoers.d/user && \
        rm -rf /var/cache/apk/*
USER user
VOLUME /home
WORKDIR /home/user
COPY entrypoint.sh /home/user/
ENTRYPOINT ["sh", "/home/user/entrypoint.sh"]
CMD []