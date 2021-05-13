FROM rubylang/ruby:3.0

RUN ls -l /bin/
RUN \
      # curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
      # echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
      apt-get update -qq && \
      apt-get install -y curl libsqlite3-dev && \
      apt-get install -y build-essential nodejs npm && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* &&\
      npm install --global yarn

ENV \
      APP_HOME=/app \
      BUNDLE_PATH=/vendor/bundle/3.0.1
RUN \
      mkdir $APP_HOME && \
      mkdir -p $BUNDLE_PATH

WORKDIR $APP_HOME

RUN gem install bundler:2.2.16
COPY Gemfile Gemfile.lock $APP_HOME/
RUN bundle install --quiet

COPY package.json yarn.lock $APP_HOME/
RUN yarn install --check-files --silent

EXPOSE ${PORT}

COPY bin/ bin/
COPY lib/ lib/
COPY *.js Rakefile ./
COPY config/ config/
COPY app/assets/ app/assets/
COPY app/javascript/ app/javascript/
RUN env SECRET_KEY_BASE=`bin/rake secret` bin/rake assets:precompile -sq

COPY . $APP_HOME/
RUN echo "${COMMIT_SHA}" > ./VERSION && cat ./VERSION

# tmp/pids/server.pid is just for docker-compose
CMD \
      rm -f tmp/pids/server.pid &&\
      bundle exec bin/rails server --binding 0.0.0.0
