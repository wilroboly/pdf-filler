FROM debian:wheezy-slim
LABEL maintainer Jack Lucky <jack.lucky.iv@gmail.com

ENV PATH_TO_PDFTK /usr/bin/pdftk

RUN apt-get update && apt-get install -y \
  ruby \
  bundler \
  ca-certificates \
  pdftk \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app
VOLUME /usr/app

CMD ruby app.rb -p 4567  -o 0.0.0.0
