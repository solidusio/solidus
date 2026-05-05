ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION-slim-buster

ARG PG_VERSION
ARG MYSQL_VERSION
ARG NODE_VERSION
ARG BUNDLER_VERSION

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    git \
    imagemagick \
    libmariadb-dev \
    sqlite3 \
    libsqlite3-dev \
    chromium \
    libvips \
    chromium-driver \
  && rm -rf /var/cache/apt/lists/*

RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' $PG_VERSION > /etc/apt/sources.list.d/pgdg.list

RUN curl -sSL https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_VERSION \
    default-mysql-client \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

ENV APP_USER=solidus_starter_frontend_user \
    LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV GEM_HOME=/home/$APP_USER/gems
ENV APP_HOME=/home/$APP_USER/app
ENV PATH=$PATH:$GEM_HOME/bin

RUN useradd -ms /bin/bash $APP_USER

RUN gem update --system \
  && gem install bundler:$BUNDLER_VERSION \
  && chown -R $APP_USER:$(id -g $APP_USER) /home/$APP_USER/gems

USER $APP_USER

RUN mkdir -p /home/$APP_USER/history

WORKDIR /home/$APP_USER/app
