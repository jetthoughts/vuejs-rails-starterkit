# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.4.3

* System dependencies: Node.js, Postgresql

* Configuration:

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Generate Rub on Rails Project with Vue.js and Turbolinks

```bash
rails new vuejs-ror-setup -M -C -S --skip-turbolinks --edge --webpack=vue -d postgresql
bundle update
yarn upgrade @rails/webpacker --latest
yarn upgrade webpack-dev-server --latest
yarn install
bin/rails test
```

2. Enable Webpacker by updating `app/views/layout/application.html.erb`:

```diff
-    <%= stylesheet_link_tag    'application', media: 'all' %>
-    <%= javascript_include_tag 'application' %>
+    <%= javascript_pack_tag 'application' %>
+    <%= javascript_pack_tag 'hello_vue' %>
```

3. Add sample page to confirm that Vue.js loaded:

```bash
bin/rails g controller Landing index --no-javascripts --no-stylesheets --no-helper --no-assets --no-fixture
bin/rails s
```
4. Setup sample page as home page by updating `config/routes.rb`:

```diff
 Rails.application.routes.draw do
   get 'landing/index'   
+  root 'landing#index'
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 end
``` 

5. Verify locally that vue.js working

open "http://localhost:3000/landing/index"
Expect to see https://cl.ly/3X43283o1f3b/Image%202018-01-22%20at%2010.04.46.public.png

## Setup Heroku and Deploy

1. Confirm compilation is working:
  
```bash
RAILS_ENV=production \
NODE_ENV=production \
RAILS_SERVE_STATIC_FILES=true \
SECRET_KEY_BASE="7aa51097e982f34be02abe83528c3308768dff3837b405e0907028c750d22d067367fb79e2b223e3f223fea50ddf2d5dc9b3c933cf5bc8c7f2a3d3d75f73c4a7" \
bin/rails assets:precompile
```

2. Create Heroku App and provision it
```bash
heroku create

heroku buildpacks:add heroku/nodejs -i 1
heroku buildpacks:add heroku/ruby -i 2

heroku config:set RAILS_ENV=production NODE_ENV=production
```

5. Verify that vue.js working on Heroku

```bash
git push heroku master
heroku apps:open
```
