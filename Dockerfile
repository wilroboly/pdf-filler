FROM debian:wheezy-slim
LABEL maintainer Jack Lucky <jack.lucky.iv@gmail.com

ENV PATH_TO_PDFTK /usr/bin/pdftk

RUN apt-get update && apt-get install -y \
  ruby \
  bundler \
  ca-certificates \
  pdftk \
  curl \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app

RUN useradd -d /usr/app webadm
RUN chown -R webadm:webadm /usr/app

COPY ./ca-certificate/ca-bundle.crt /usr/local/share/ca-certificates/
RUN /usr/sbin/update-ca-certificates

USER webadm


CMD ruby app.rb -p 4567  -o 0.0.0.0
