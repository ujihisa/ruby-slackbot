# FROM rubylang/ruby:3.0.2-focal
FROM rubylang/3.1.0-preview1-focal

RUN \
      apt-get update -qq && \
      apt-get install -y curl libsqlite3-dev && \
      apt-get install -y build-essential nodejs npm && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/*

ENV \
      APP_HOME=/app \
      BUNDLE_PATH=/vendor/bundle/3.1.0-preview1

RUN gem install bundler:2.2.16

RUN mkdir $APP_HOME && chown ubuntu $APP_HOME
RUN mkdir -p $BUNDLE_PATH && chown ubuntu $BUNDLE_PATH
USER ubuntu

WORKDIR $APP_HOME

COPY --chown=ubuntu Gemfile Gemfile.lock ./
RUN bundle install --quiet

EXPOSE ${PORT}

COPY --chown=ubuntu bin/ ./bin/
COPY --chown=ubuntu lib/ ./lib/
COPY --chown=ubuntu *.js Rakefile ./
COPY --chown=ubuntu config/ ./config/
COPY --chown=ubuntu app/assets/ ./app/assets/
COPY --chown=ubuntu app/javascript/ ./app/javascript/
RUN env SECRET_KEY_BASE=`bin/rake secret` ./bin/rake assets:precompile -sq

COPY --chown=ubuntu . ./
RUN echo "${COMMIT_SHA}" > ./VERSION && cat ./VERSION

# tmp/pids/server.pid is just for docker-compose
RUN rm -f ./tmp/pids/server.pid

CMD ["bundle", "exec", "bin/rails", "server", "--binding", "0.0.0.0"]
