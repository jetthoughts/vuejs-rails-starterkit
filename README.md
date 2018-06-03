# README

Things you may want to cover:

* Ruby version: 2.5.1

* System dependencies: Node.js, Yarn, PostgreSQL

## Generate Ruby on Rails Project with Vue.js and Turbolinks

```bash
rails new vuejs-ror-setup -M -C -S --skip-turbolinks --webpack=vue -d postgresql
bundle update
yarn upgrade @rails/webpacker --latest
yarn upgrade webpack-dev-server --latest
yarn install
bin/rails test
```
2. Enable `unsafe-eval rule` to support runtime-only build

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
You can read more about this in the [Vue docs](https://vuejs.org/v2/guide/installation.html#CSP-environments).

3. Enable Webpacker by updating `app/views/layout/application.html.erb`:

```diff
-    <%= stylesheet_link_tag    'application', media: 'all' %>
-    <%= javascript_include_tag 'application' %>
+    <%= javascript_pack_tag 'application' %>
+    <%= javascript_pack_tag 'hello_vue' %>
```

4. Delete deprecated option from `app/config/webpack/loaders/vue.js`:

```diff
    const inDevServer = process.argv.find(v => v.includes('webpack-dev-server'))
-   const extractCSS = !(inDevServer && (devServer && devServer.hmr)) || isProduction

 module.exports = {
   test: /\.vue(\.erb)?$/,
   use: [{
-    loader: 'vue-loader',
-    options: { extractCSS }
+    loader: 'vue-loader'
   }]
 }
```

5. Add sample page to confirm that Vue.js loaded:

```bash
bin/rails g controller Landing index --no-javascripts --no-stylesheets --no-helper --no-assets --no-fixture
bin/rails s
```
6. Setup sample page as home page by updating `config/routes.rb`:

```diff
 Rails.application.routes.draw do
   get 'landing/index'   
+  root 'landing#index'
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
 end
``` 

7. Verify locally that vue.js working

`open "http://localhost:3000/landing/index"`

Expect to see ![](https://cl.ly/3X43283o1f3b/Image%202018-01-22%20at%2010.04.46.public.png)

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

## Setup Vue.js code conventions

1. Install vue.js official babel preset

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

