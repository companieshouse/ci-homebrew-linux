FROM amazonlinux:2 AS final
FROM amazonlinux:2 AS build

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
    rubygems \
    curl \
    tar \
    gzip && \
    yum clean all

RUN mkdir -p /home/linuxbrew/.linuxbrew && \
    curl -L https://github.com/Homebrew/brew/tarball/HEAD \
    | tar xz --strip 1 -C /home/linuxbrew/.linuxbrew

RUN useradd -m -s /bin/bash linuxbrew && \
    chown -R linuxbrew:linuxbrew /home/linuxbrew

FROM final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG ENV_FILE="/home/linuxbrew/.bashrc"

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

RUN useradd -m -s /bin/bash linuxbrew

RUN mkdir -p /home/linuxbrew > /dev/null 2>&1

COPY --from=build --chown=linuxbrew:linuxbrew /home/linuxbrew /home/linuxbrew

RUN echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> "$BASH_ENV" && \
    rm -rf /usr/share/doc /usr/share/locale /usr/share/man > /dev/null 2>&1

USER linuxbrew
WORKDIR /home/linuxbrew

ENTRYPOINT ["/bin/bash", "-c"]
