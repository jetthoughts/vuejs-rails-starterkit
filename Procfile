release: bin/heroku-release
web: bin/bundle exec puma -C config/puma.rb
worker: RAILS_MAX_THREADS=$SIDEKIQ_CONCURRENCY bin/bundle exec sidekiq -e $RAILS_ENV
