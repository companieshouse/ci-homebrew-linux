FROM amazonlinux:2 as final
FROM amazonlinux:2 as build

SHELL ["/bin/bash", "-c"]

ENV HOMEBREW_INSTALL_FROM_API=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1

RUN amazon-linux-extras enable ruby3.0 && \
    yum -y groupinstall 'Development Tools' && \
    yum -y install \
    git \
    procps-ng \
    ruby \
    ruby-irb \
    rubygem-rake \
    rubygem-json \
    rubygems && \
    yum clean all

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

FROM final

SHELL ["/bin/bash", "-c"]

ARG ENV_FILE="/root/.bashrc"

ENV HOMEBREW_INSTALL_FROM_API=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV BASH_ENV=${ENV_FILE}

RUN yum -y install \
    gcc \
    git \
    gzip \
    procps-ng \
    tar && \
    yum clean all

RUN mkdir -p /home/linuxbrew > /dev/null 2>&1

COPY --from=build /home/linuxbrew /home/linuxbrew

RUN /home/linuxbrew/.linuxbrew/bin/brew shellenv >> $BASH_ENV && \
    /home/linuxbrew/.linuxbrew/bin/brew cleanup --prune=all

RUN rm -rf \
    /usr/share/doc \
    /usr/share/locale \
    /usr/share/man > /dev/null 2>&1

ENTRYPOINT ["/bin/bash", "-c"]
