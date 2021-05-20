# README

## Development

Use docker-compose run "ruby-slackbot" for develop.

```
docker-compose up -d yaichi && docker-compose up --build ruby-slackbot
```

Open http://localhost in your browser

## Testing

```
docker-compose build -q ruby-slackbot && docker-compose run --rm ruby-slackbot bin/rails test test:integration
```

## Manual deploy

Replace the tag with the current sha1.
Use this only when you need to test the deployment itself.

```
docker build -t gcr.io/devs-sandbox/ruby-slackbot:55312fcc7b4be42e08d9ef52966224663aad3207 .
docker push gcr.io/devs-sandbox/ruby-slackbot:55312fcc7b4be42e08d9ef52966224663aad3207
gcloud run deploy ruby-slackbot --image gcr.io/devs-sandbox/ruby-slackbot:55312fcc7b4be42e08d9ef52966224663aad3207 --region us-central1 --platform managed --allow-unauthenticated
```

## Licence

Copyright Tatsuhiro Ujihisa

GPLv3 or any later versions
