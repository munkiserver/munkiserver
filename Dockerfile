FROM ruby:2.2.2

ENV APP_HOME /opt/app
RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME

RUN gem install --no-document bundler rails

COPY ./Gemfile* $APP_HOME/
RUN bundle install --without=development,test

# Put the app on the server (only the good parts)
COPY ./Rakefile $APP_HOME/
COPY ./app/ $APP_HOME/app
COPY ./config.ru $APP_HOME/
COPY ./config/ $APP_HOME/config
COPY ./db/ $APP_HOME/db
COPY ./lib/ $APP_HOME/lib
COPY ./public/ $APP_HOME/public
COPY ./script/ $APP_HOME/script
COPY ./vendor/ $APP_HOME/vendor

RUN mkdir packages

ENV RAILS_ENV production
ENV RACK_ENV production
ENV PORT 3000

# CMD ["./script/rails", "server"]
CMD ["rails", "server"]
