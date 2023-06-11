FROM debian:bookworm

MAINTAINER dev@mirantis.com

ARG DIST=squeeze
ARG APTLY_VERSION=1.5.0
ENV DEBIAN_FRONTEND noninteractive

# Install aptly and required tools
RUN apt-get -q update                     \
    && apt-get -y install bash-completion \
                          bzip2           \
                          gnupg1          \
                          gpg             \
                          gpgv            \
                          gpgv1           \
                          graphviz        \
                          wget            \
                          xz-utils        \
                          gosu

RUN wget -qO- https://www.aptly.info/pubkey.txt | gpg --dearmor | \
      tee /etc/apt/keyrings/aptly.gpg >/dev/null \
    && echo "deb [ signed-by=/etc/apt/keyrings/aptly.gpg ] http://repo.aptly.info/ $DIST main" \
      >> /etc/apt/sources.list.d/aptly.list

RUN apt-get update \
    && apt-get -y install aptly=$APTLY_VERSION \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/aptly.conf /etc/aptly.conf
COPY files/*.sh /usr/local/bin/
COPY files/entrypoint.sh /entrypoint.sh

# Enable Aptly Bash completions
RUN echo "if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi" >> /etc/bash.bashrc

VOLUME ["/var/lib/aptly"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
