FROM rubylang/ruby:3.0

RUN \
      apt-get update -qq && \
      apt-get install -y curl libsqlite3-dev && \
      apt-get install -y build-essential nodejs npm && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* &&\
      npm install --global yarn

ENV \
      APP_HOME=/app \
      BUNDLE_PATH=/vendor/bundle/3.0.1

RUN gem install bundler:2.2.16

RUN mkdir $APP_HOME && chown ubuntu $APP_HOME
RUN mkdir -p $BUNDLE_PATH && chown ubuntu $BUNDLE_PATH
USER ubuntu

WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock ./
RUN bundle install --quiet

COPY package.json yarn.lock ./
RUN yarn install --check-files --silent

EXPOSE ${PORT}

COPY bin/ ./bin/
COPY lib/ ./lib/
COPY *.js Rakefile ./
COPY config/ ./config/
COPY app/assets/ ./app/assets/
COPY app/javascript/ ./app/javascript/
RUN env SECRET_KEY_BASE=`bin/rake secret` ./bin/rake assets:precompile -sq

COPY . ./
RUN echo "${COMMIT_SHA}" > ./VERSION && cat ./VERSION

# tmp/pids/server.pid is just for docker-compose
RUN rm -f ./tmp/pids/server.pid

CMD ["bundle", "exec", "bin/rails", "server", "--binding", "0.0.0.0"]
