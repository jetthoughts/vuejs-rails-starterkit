# Setting up Rails 5.2 with PWA, Turbolinks, Webpack(er) 4, Babel 7, Vue.js 2.5 and Jest.

A quick and easy way to setup Rails + PWA + Turbolinks + Webpacker + Vue + Jest.
If your team is considering, or has already decided, to use Vue, this is the right for you.
As extra review how to setup PWA, Turbolinks, CSS frameworks, Storybook.

Things you may want to cover:

* [Ruby](https://www.ruby-lang.org/en/) version: 2.5.3

* System dependencies: [Node.js](https://nodejs.org/en/), [Yarn](https://yarnpkg.com/en/), [PostgreSQL](https://www.postgresql.org/), [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

* Key Dependencies: [Ruby on Rails](https://rubyonrails.org/) version 5.2, [Vue.js](https://vuejs.org) version 2.5, [Webpacker](https://github.com/rails/webpacker) with Webpack 4 and Babel 7

## Generate Ruby on Rails Project with Vue.js (No Turbolinks included on this stage)

```bash
gem install rails -v 5.2

rails new vuejs-rails-5-starterkit -M -C -S --skip-turbolinks --webpack=vue -d postgresql
cd ./vuejs-rails-5-starterkit

bin/rails db:create db:migrate
```

### Setup development environment:

1. Uncomment `system('bin/yarn')` in `bin/setup` and `bin/update` to
install new node modules.

2. Install dependencies:

```bash
bin/setup
```
3. Enable *unsafe-eval rule* to support runtime-only build and
   *webpacker-dev-server*

This can be done in the `config/initializers/content_security_policy.rb` with the following
configuration:

```ruby
Rails.application.config.content_security_policy do |policy|
  if Rails.env.development?
    policy.script_src :self, :https, :unsafe_eval
    policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035'
  else
    policy.script_src :self, :https
  end
end
```

You can learn more about this from: [Vue.js Docs](https://vuejs.org/v2/guide/installation.html#CSP-environments) and [Webpacker/Vue Docs](https://github.com/rails/webpacker#vue).

4. Verify that we have not broken anything

```bash
bin/webpack
bin/rails runner "exit"
```

### Upgrade to Webpacker 4

1. Update `Gemfile` to use new version:

```ruby
gem 'webpacker', '>= 4.0.x'
```

2. Install new Webpacker and update application

```bash
bundle update webpacker
bin/rails webpacker:install
bin/rails webpacker:install:vue
```

3. Upgraded packages by Yarn too

```bash
yarn add @rails/webpacker@next
yarn upgrade webpack-dev-server --latest
yarn install
```

4. Verify that everything is still working

```bash
bin/webpack
bin/rails test
```

### Enable Vue.js single-file components to make examples works

1. Install `@vue/babel-preset-app`:

```bash
yarn add @vue/babel-preset-app
```

2. Replace `@babel/preset-env` with `@vue/app` in `.bablerc`

3. Verify by: `bin/webpack`


### Use Webpacker assets in the application

2. Enable Webpacker by updating `app/views/layout/application.html.erb`:

Replace:

```erb
    <%= stylesheet_link_tag    'application', media: 'all' %>
    <%= javascript_include_tag 'application' %>
```

with:

```erb
    <%= stylesheet_pack_tag 'hello_vue', media: 'all' %>
    <%= javascript_pack_tag 'hello_vue' %>
```

3. Add sample page to host Vue.js component:

```bash
bin/rails g controller Landing index --no-javascripts --no-stylesheets --no-helper --no-assets --no-fixture
```

4. Setup sample page as home page by updating `config/routes.rb`:

```ruby
  root 'landing#index'
```

7. Verify locally that vue.js working

```bash
bin/rails s
open "http://localhost:3000/"
```

Expect to see ![](https://user-images.githubusercontent.com/125715/41176720-28eb3268-6b6a-11e8-9cb8-29cd78155d1b.png)

## Install Jest for Component Unit Tests

1. Add Jest

```bash
yarn add --dev jest vue-jest babel-jest @vue/test-utils jest-serializer-vue 'babel-core@^7.0.0-bridge' @babel/core
```

2. Add to `package.json`:

```json
  "scripts": {
    "test": "jest"
  },
  "jest": {
    "verbose": true,
    "testURL": "http://localhost/",
    "roots": [
      "test/javascript"
    ],
    "moduleDirectories": [
      "node_modules",
      "app/javascript"
    ],
    "moduleNameMapper": {
      "^@/(.*)$": "app/javascript/$1"
    },
    "moduleFileExtensions": [
      "js",
      "json",
      "vue"
    ],
    "transform": {
      "^.+\\.js$": "<rootDir>/node_modules/babel-jest",
      ".*\\.(vue)$": "<rootDir>/node_modules/vue-jest"
    },
    "snapshotSerializers": [
      "<rootDir>/node_modules/jest-serializer-vue"
    ]
  },
```

3. Add to `.babelrc`:

```json
  "env": {
    "test": {
      "presets": [
        ["@babel/preset-env", {
          "targets": {
            "node": "current"
          }
      }]]
  }},
```

4. Add `test/javascript/test.test.js`:

```js
test('there is no I in team', () => {
  expect('team').not.toMatch(/I/);
});
```

5. Verify installation

```bash
yarn test
```

You should found ![](https://cl.ly/3y0d2E110c3H/Image%202018-03-31%20at%2019.18.54.public.png)

6. Add component test for App in `test/javascript/app.test.js`:

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

7. Verify by

```bash
yarn test
```

You should see all tests passed

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

Requirements: [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install).

**NOTE:** Do not forget to commit all your changes: `git add . && git
commit -m "Generates Ruby on Rails application with Vue.js onboard"`


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

## Setup basic PWA

1. Install `serviceworker-rails` by adding into `Gemfile`:

```ruby
gem 'serviceworker-rails', github: 'rossta/serviceworker-rails'
```

2. By following guide: https://github.com/rossta/serviceworker-rails
   should get something to: https://gist.github.com/pftg/786b147eff85a6fc98bd8dc1c3c9778e

## Setup Turbolinks

1. Add node dependencies

```bash
yarn add vue-turbolinks turbolinks
yarn install
```

2. Load Turbolinks by adding
   `app/javascript/initializers/turbolinks.js`:

```javascript
import Turbolinks from 'turbolinks'
Turbolinks.start()
```

3. Update `app/javascript/packs/application.js`:

```javascript
import 'initializers/turbolinks.js'
```

4. Uncomment in `hello_vue.js`:

```javascript
import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import App from '../app.vue'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    el: '#hello',
    data: {
      message: "Can you say hello?"
    },
    components: { App }
  })
})
```

5. Update layout with:

```html
<div id="hello"></div>
```

6. Run tests and server to verify:

```bash
bin/rails t
bin/rails s
```
