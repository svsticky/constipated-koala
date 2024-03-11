FROM ruby:3.0.5

# For some reason, Debian doesn't package yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update
RUN apt-get install -y nodejs curl imagemagick ghostscript mupdf yarn postgresql-client

WORKDIR /app

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN bundler install

ADD package.json package.json
ADD yarn.lock yarn.lock

RUN yarn install

ADD . .

RUN rails assets:precompile
