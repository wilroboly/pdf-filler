FROM alpine:3.7
MAINTAINER Jack Lucky <jack.lucky.iv@gmail.com

ENV PATH_TO_PDFTK /usr/bin/pdftk
ENV OTHER_PACKAGES pdftk
ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base zlib-dev
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $OTHER_PACKAGES && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install

COPY . /usr/app
VOLUME /usr/app

CMD ruby app.rb -p 4567  -o 0.0.0.0
