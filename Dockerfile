FROM ruby:3.0.0-preview1

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.1.2
ADD . $APP_HOME
RUN bundle install

EXPOSE ${PORT}

RUN yarn install --check-files
# RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN bundle exec rake assets:precompile
CMD ["rails", "server", "-b", "0.0.0.0"]
