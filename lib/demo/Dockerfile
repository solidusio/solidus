#
# This image is intended to be used to test and demo Solidus
# it is not intended for production purposes 
#
FROM ruby:2.5.1

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /solidus

WORKDIR /solidus

ADD . /solidus

RUN bundle install

RUN bundle exec rake sandbox

CMD ["sh", "./lib/demo/docker-entrypoint.sh"]