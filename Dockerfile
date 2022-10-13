FROM amazonlinux:2

ARG ENV_FILE="/root/.bashrc"

ENV HOMEBREW_INSTALL_FROM_API=1
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV BASH_ENV=${ENV_FILE}

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

RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew cleanup --prune=all

RUN echo -e "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\n$(cat ${ENV_FILE})" > ${ENV_FILE}

RUN rm -rf \
    /usr/share/doc \
    /usr/share/locale \
    /usr/share/man > /dev/null 2>&1

ENTRYPOINT ["/bin/bash", "-c"]
