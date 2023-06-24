# README

## Development

Use docker-compose run "ruby-slackbot" for develop.

```bash
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
docker build -t "gcr.io/devs-sandbox/ruby-slackbot:latest" .
docker push "gcr.io/devs-sandbox/ruby-slackbot:latest"
gcloud run deploy ruby-slackbot --image "gcr.io/devs-sandbox/ruby-slackbot:latest" --region us-central1 --platform managed --allow-unauthenticated
```

## See logs

gcloud command line option seems to be crazy

```sh
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$(basename `pwd`)" --project devs-sandbox --limit 10 --format 'value(receiveTimestamp, textPayload)'
```

## Licence

Copyright Tatsuhiro Ujihisa

GPLv3 or any later versions
