# README

## Development

Use docker-compose run "ruby-slackbot" for develop.

```
docker-compose -d ruby-slackbot yaichi
```

Open http://localhost in your browser

## Testing

```
docker-compose build -q ruby-slackbot && docker-compose run --rm ruby-slackbot bin/rails test test:integration
```


## Licence

Copyright Tatsuhiro Ujihisa

GPLv3 or any later versions
