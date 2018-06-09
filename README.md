# README

Things you may want to cover:

* [Ruby](https://www.ruby-lang.org/en/) version: 2.5.1

* System dependencies: [Node.js](https://nodejs.org/en/), [Yarn](https://yarnpkg.com/en/), [PostgreSQL](https://www.postgresql.org/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

* Key Dependencies: [Ruby on Rails](https://rubyonrails.org/) version 5.2, [Vue.js](https://vuejs.org) version 2.5, [Webpacker](https://github.com/rails/webpacker) for Webpack version 4

## Generate Ruby on Rails Project with Vue.js (No Turbolinks included on this stage)

```bash
gem install rails -v 5.2

rails new vuejs-ror-setup -M -C -S --skip-turbolinks --webpack=vue -d postgresql
cd ./vuejs-ror-setup

bin/setup
bin/update

bin/rails test
```

## Upgrade to Webpacker 4

1. Update `Gemfile` to use new version:

```ruby
gem 'webpacker', '>= 4.0.x'
```

2. Install new Webpacker and update application

```bash
bundle update webpacker
bundle exec rails webpacker:install:vue
```

3. Upgraded packages by Yarn too

```bash
yarn add @rails/webpacker@~4.0.0-pre.2 
yarn upgrade webpack-dev-server --latest
yarn install
```

4. Verify that everything is still working

```bash
bin/rails test
```

## Use Webpacker

1. Enable `unsafe-eval rule` to support runtime-only build

This can be done in the `config/initializers/content_security_policy.rb` with the following
configuration:

```ruby
Rails.application.config.content_security_policy do |policy|
  if Rails.env.development?
    policy.script_src :self, :https, :unsafe_eval
  else
    policy.script_src :self, :https
  end
end
```

You can learn more about this from: [Vue.js Docs](https://vuejs.org/v2/guide/installation.html#CSP-environments) and [Webpacker/Vue Docs](https://github.com/rails/webpacker#vue).

2. Enable Webpacker by updating `app/views/layout/application.html.erb`:

```diff
-    <%= stylesheet_link_tag    'application', media: 'all' %>
-    <%= javascript_include_tag 'application' %>
+    <%= stylesheet_pack_tag 'hello_vue', media: 'all' %>
+    <%= javascript_pack_tag 'hello_vue' %>
```

3. Add sample page to confirm that Vue.js loaded:

```bash
bin/rails g controller Hello index --no-javascripts --no-stylesheets --no-helper --no-assets --no-fixture
bin/rails s
```

4. Setup sample page as home page by updating `config/routes.rb`:

```diff
 Rails.application.routes.draw do
+  root 'hello#index'
+
   get 'hello/index'   
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 end
``` 

7. Verify locally that vue.js working

`open "http://localhost:3000/"`

Expect to see ![](https://user-images.githubusercontent.com/125715/41176720-28eb3268-6b6a-11e8-9cb8-29cd78155d1b.png)

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

Requirements: [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install)

```bash
heroku create

heroku buildpacks:add heroku/ruby

heroku config:set RAILS_ENV=production NODE_ENV=production
```

5. Deploy and verify that vue.js working on Heroku

```bash
git push heroku master

heroku apps:open
```

## Setup Vue.js code conventions

1. Install vue.js official babel preset

*NOTE:* Ruby on Rails + Webpacker do not support babel presets installed in development dependencies.

```bash
yarn add babel-preset-vue-app
```

2. Update `.babelrc` with:

```diff
 {
   "presets": [
+    "vue-app",
     ["env", {
       "modules": false,
```

## Install Jest for Component Unit Tests

1. Add Jest

```bash
yarn add --dev jest vue-jest babel-jest @vue/test-utils jest-serializer-vue
```

2. Update `package.json`

```diff
 {
   "name": "vuejs-ror-setup",
   "private": true,
+  "scripts": {
+    "test": "jest"
+  },
+  "jest": {
+    "roots": [
+      "test/javascript"
+    ],
+    "moduleDirectories": [
+      "node_modules",
+      "app/javascript"
+    ],
+    "moduleNameMapper": {
+      "^@/(.*)$": "app/javascript/$1"
+    },
+    "moduleFileExtensions": [
+      "js",
+      "json",
+      "vue"
+    ],
+    "transform": {
+      "^.+\\.js$": "<rootDir>/node_modules/babel-jest",
+      ".*\\.(vue)$": "<rootDir>/node_modules/vue-jest"
+    },
+    "snapshotSerializers": [
+      "<rootDir>/node_modules/jest-serializer-vue"
+    ]
+  },
   "dependencies": {
     "@rails/webpacker": "^3.4.1",
```

2. Update `.babelrc`:

```diff
   "presets": [
     "vue-app",
     ["env", {
       "modules": false,
       "targets": {
         "browsers": "> 1%",
         "uglify": true
       },
       "useBuiltIns": true
     }]
   ],   
+  "env": {
+    "test": {
+      "presets": [
+        ["env", {
+          "targets": {
+            "node": "current"
+          }
+      }]]
+  }},
   "plugins": [
     "syntax-dynamic-import",
     "transform-object-rest-spread",
```

2. Add `test/javascript/test.test.js`:

```js
test('there is no I in team', () => {
  expect('team').not.toMatch(/I/);
});
```

3. Verify installation

```bash
yarn test
```

You should found ![](https://cl.ly/3y0d2E110c3H/Image%202018-03-31%20at%2019.18.54.public.png)

4. Add component test for App in `test/javascript/app.test.js`:

```js
import { mount, shallowMount } from '@vue/test-utils'
import App from 'app';

describe('App', () => {
  test('is a Vue instance', () => {
    const wrapper = mount(App)
    expect(wrapper.isVueInstance()).toBeTruthy()
  })

  test('matches snapshot', () => {
    const wrapper = shallowMount(App)
    expect(wrapper.html()).toMatchSnapshot()
  })
});
```

5. Verify by

```bash
yarn test
```

You should see all tests passed

