FROM ruby:2.2.2

ENV APP_HOME /opt/app
RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME

RUN gem install --no-document bundler rails

COPY ./Gemfile* $APP_HOME/
RUN bundle install --without=development,test

# Put the app on the server (only the good parts)
COPY . $APP_HOME
COPY ./config/database.yml.example $APP_HOME/config/database.yml

RUN mkdir packages

# Set production env vars
ENV RAILS_ENV production
ENV RACK_ENV production
ENV PORT 3000

# CMD ["./script/rails", "server"]
EXPOSE 3000
CMD ["rails", "server"]
