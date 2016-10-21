FROM ruby:1.9.3
MAINTAINER Yves Brissaud <yves@sogilis.com>
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install --without test development --jobs 20 --retry 5
COPY . /usr/src/app
CMD ["bundle", "exec", "rackup"]
