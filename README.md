# Rails 6 + Vue.js 2 Starter Kit GitHub Template.

**NOTE:** For Rails 5.2, please check
https://github.com/jetthoughts/vuejs-rails-starterkit/tree/rails-5-latest

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)
![GitHub Actions Test](https://github.com/jetthoughts/vuejs-rails-starterkit/workflows/Test/badge.svg)
[![CircleCI Test](https://circleci.com/gh/jetthoughts/vuejs-rails-starterkit.svg?style=svg)](https://circleci.com/gh/jetthoughts/vuejs-rails-starterkit)
[![codecov](https://codecov.io/gh/jetthoughts/vuejs-rails-starterkit/branch/master/graph/badge.svg)](https://codecov.io/gh/jetthoughts/vuejs-rails-starterkit)

A quick and easy way to setup Rails + PWA + Turbolinks + Webpacker + Bootstrap with AdminLTE theme + Vue + Jest.
If your team is considering or has already decided to use Vue, this is the right for you.
As an additional review of how to setup PWA, Turbolinks, CSS frameworks, Storybook.

### Preview of all steps
[![asciicast](https://asciinema.org/a/ArqvGrc6JK6pKzlRTMV3Jotwr.svg)](https://asciinema.org/a/ArqvGrc6JK6pKzlRTMV3Jotwr)

### Expected Final Screen
![image](https://user-images.githubusercontent.com/53345298/80085750-586bc080-8561-11ea-8c3b-dc1eab5b9200.png)

## Table of Contents
- [Step 1. Generate Ruby on Rails Project with Vue.js](#generate-ruby-on-rails-project-with-vuejs-no-turbolinks-included-on-this-stage)
- [Step 2. Setup development environment](#setup-development-environment)
- [Step 3. Add sample page to host Vue.js component](#add-sample-page-to-host-vuejs-component)
- [Step 4. Use Webpacker assets in the application](#use-webpacker-assets-in-the-application)
- [Step 5. Install Jest for Component Unit Tests](#install-jest-for-component-unit-tests)
- [Step 6. Setup Heroku and Deploy](#setup-heroku-and-deploy)
- [Step 7. Setup basic PWA](#setup-basic-pwa)
- [Step 8. Setup Turbolinks](#setup-turbolinks)
- [Step 9. Installs UI Kit - AdminLTE](#setup-adminlte)
- [Step 10. Configure continuous integration and other services for static code
  analysis](#configure-continuous-integration-and-other-services-for-static-code-analysis)


#### Things you may want to cover:

#### Features:

* Optimized for peformance Webpacker with Vue.js: Lazy Load, Split Chunks
* Turbolinks
* PWA
* Backend Unit and System Tests with coverage
* Vue.js Unit Tests with coverage
* Deployable to Heroku
* Pre-setup for services:
    - GitHub
    - Heroku (Heroku Reviews Apps)
    - CircleCI
    - Codecov and Simplecov
    - Dependabot
* Static Code Analyzers:
    - Pronto
    - Rubocop
    - ESLint
    - EditorConfig


#### Dependencies:

* [Ruby on Rails](https://rubyonrails.org/) version 6
* [Vue.js](https://vuejs.org) version 2 with [Vue Test Utils](https://vue-test-utils.vuejs.org/)
* [Webpacker](https://github.com/rails/webpacker) 5 with [Webpack](https://webpack.js.org/) 4
* [Bootstrap](https://getbootstrap.com/) 4 with [AdminLTE Template](https://adminlte.io/)
* [Babel](https://babeljs.io/) 7

#### System Dependencies:

* [Ruby](https://www.ruby-lang.org/en/) 3.0
* [Node.js](https://nodejs.org/en/) 14
* [Yarn](https://yarnpkg.com/en/)
* [PostgreSQL](https://www.postgresql.org/) 12
* [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

## Generate Ruby on Rails Project with Vue.js (No Turbolinks included on this stage)

```bash
gem install rails

rails new vuejs-rails-starterkit --force --database=postgresql \
  --skip-action-mailer --skip-action-cable --skip-sprockets --skip-turbolinks \
  --webpack=vue

cd ./vuejs-rails-starterkit

bin/rails db:create db:migrate
```

This generates Rails project with:

 - Vue component in `app/javascript/app.vue`
 - Example entry file `app/javascript/packs/hello_vue.js`

### Setup development environment:

1. Uncomment `system('bin/yarn')` in `bin/setup` and `bin/update` to
install new node modules.

2. Install dependencies:

```bash
bin/setup
```
3. Enable *content_security_policy* in the `config/initializers/content_security_policy.rb`
with the following configuration:

```ruby
Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https

  if Rails.env.development? || Rails.env.test?
    policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035'
  end
end
```
4. Verify that we have not broken anything

```bash
bin/webpack
bin/rails runner "exit"
```

### Add sample page to host Vue.js component

1. Generate controller and view:

```bash
bin/rails generate controller Landing index --no-javascripts --no-stylesheets --no-helper --no-assets --no-fixture
```

2. Update `app/views/landing/index.html.erb` to:

```erb
<h1>Landing#index</h1>
<p>Find me in app/views/landing/index.html.erb</p>

<div id='hello_vue_app'></div>
```

3. Change `app/javascript/packs/hello_vue.js` to:

```javascript
import Vue from 'vue'
import App from '../app.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    render: h => h(App),
    el: '#hello_vue_app'
  }).$mount()
})
```

4. Setup a sample page as a home page by updating `config/routes.rb`:

```ruby
  root 'landing#index'
```

### Use Webpacker assets in the application

1. Enable Webpacker with `SplitChunks`:

   * Enable `SplitChunks` with default config by adding to `config/webpack/environment.js`:

     ```js
     environment.splitChunks()
     ```

   * Enable Webpacker by updating `app/views/layouts/application.html.erb`:

     Change:

     ```erb
     <%= stylesheet_link_tag 'application', media: 'all' %>
     <%= javascript_pack_tag 'application' %>
     ```

     to:

     ```erb
     <%= stylesheet_packs_with_chunks_tag 'application', 'hello_vue', media: 'all' %>
     <%= javascript_packs_with_chunks_tag 'application', 'hello_vue' %>
     ```

2. Verify locally that vue.js is working and `SplitChunks` is enabled

```bash
bin/rails s
open "http://localhost:3000/"
```

Expect to see
![](https://user-images.githubusercontent.com/8617866/79469404-ca478580-8008-11ea-8b1a-e74cdc906183.png)

The `javascript_packs_with_chunks_tag` and `stylesheet_packs_with_chunks_tag` helpers split assets
into small size chunks and create html tags for them:

```html
<script src="/packs/js/runtime~hello_vue-818eba5af0151079cb6c.js"></script>
<script src="/packs/js/1-7b962b4481d6abff6c2b.chunk.js"></script>
<script src="/packs/js/hello_vue-bc0218ac204eff3ff742.chunk.js"></script>
```

## Install Jest for Component Unit Tests

1. Add Jest with required dependencies

```bash
yarn add --dev jest @vue/test-utils vue-jest babel-core@^7.0.0-bridge.0 babel-jest jest-serializer-vue
```

2. Configure Jest in `package.json` (including the Coverage enabling):

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
      "^@/(.*)$": "<rootDir>/app/javascript/$1"
    },
    "moduleFileExtensions": [
      "js",
      "json",
      "vue"
    ],
    "transform": {
      ".+\\.js$": "babel-jest",
      ".+\\.vue$": "vue-jest"
    },
    "testPathIgnorePatterns": [
      "<rootDir>/config/webpack/"
    ],
    "snapshotSerializers": [
      "jest-serializer-vue"
    ],
    "collectCoverage": true,
    "collectCoverageFrom": [
      "**/*.{js,vue}",
      "!**/node_modules/**"
    ]
  },
```

3. Add `test/javascript/test.test.js`:

```js
test('there is no I in team', () => {
  expect('team').not.toMatch(/I/);
});
```

4. Verify installation

```bash
yarn test
```

Expect to see ![](https://cl.ly/3y0d2E110c3H/Image%202018-03-31%20at%2019.18.54.public.png)

6. Add component test for App in `test/javascript/app.test.js`:

```js
import { mount, shallowMount } from '@vue/test-utils'
import App from 'app';

describe('App', () => {
  test('is a Vue instance', () => {
    const wrapper = mount(App)
    expect(wrapper.vm).toBeTruthy()
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

2. Create a Heroku App and provision it

Requirements: [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install).

**NOTE:** Do not forget to commit all your changes: `git add . && git
commit -m "Generates Ruby on Rails application with Vue.js onboard"`


```bash
heroku create

heroku addons:create heroku-postgresql:hobby-dev

heroku buildpacks:add heroku/ruby

heroku config:set RAILS_ENV=production NODE_ENV=production YARN_PRODUCTION=true MALLOC_ARENA_MAX=2
```

3. Setup Node.js for Heroku

```bash
heroku buildpacks:add --index 1 heroku/nodejs
```

Use the `engines` section of the `package.json` to specify the version of Node.js to use on Heroku.
Drop the ‘v’ to save only the version number:

```json
{
  "engines": {
    "node": ">= 12.x"
  }
}
```

4. Deploy and verify that vue.js is working on Heroku

```bash
git push heroku master

heroku apps:open
```

## Setup basic PWA

1. Install `serviceworker-rails` by adding into `Gemfile`:

```ruby
gem 'serviceworker-rails', github: 'rossta/serviceworker-rails'
```

2. Following the guide: https://github.com/rossta/serviceworker-rails
   you should get something like: https://gist.github.com/pftg/786b147eff85a6fc98bd8dc1c3c9778e

3. There'll be an issue with service worker registration on the page saying:
`Uncaught ReferenceError: window is not defined` and
`Failed to register a ServiceWorker...`.
To fix that add following line to `config/webpack/environment.js`
as suggested [here](https://github.com/webpack/webpack/issues/6642#issuecomment-371087342):

```javascript
environment.config.set('output.globalObject', 'this')
```

## Setup Turbolinks

1. Add node dependencies

```bash
yarn add vue-turbolinks turbolinks
```

2. Load Turbolinks by adding to
   `app/javascript/initializers/turbolinks.js`:

```javascript
import Turbolinks from 'turbolinks'
Turbolinks.start()
```

3. Add to `app/javascript/packs/application.js`:

```javascript
import 'initializers/turbolinks.js'
```

4. Change `app/javascript/packs/hello_vue.js` to:

```javascript
import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue'
import App from '../app.vue'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    render: h => h(App),
    el: '#hello_vue_app'
  }).$mount()
})

```

5. Update layout `app/views/layouts/application.html.erb`:

```erb
<%= javascript_packs_with_chunks_tag 'hello_vue', 'application', 'data-turbolinks-track': 'reload' %>
```

6. Run tests and server to verify:

```bash
bin/rails t
bin/rails s
```

## Setup AdminLTE

1. Add node dependencies

```bash
yarn add admin-lte bootstrap jquery popover @fortawesome/fontawesome-free
```

2. Add `app/javascript/initializers/adminlte.js` initializer:

```javascript
import '../assets/adminlte.scss'
import('./plugins') // () needed for async loading
```

3. Add `app/javascript/initializers/plugins.js` file with plugin importing:

```javascript
import '@fortawesome/fontawesome-free'
import 'jquery/src/jquery.js'
import 'popper.js'
import 'bootstrap'
import 'admin-lte/build/js/AdminLTE'
```

4. Import admin lte initializer in `app/javascript/packs/application.js` pack:

```javascript
import 'initializers/adminlte'
```

5. Next step is updating main layout `app/views/layouts/application.html.erb`. Code for layout you can find [here](https://adminlte.io/themes/v3/starter.html).
Also don't forget to add `yield` in div with `content` class:

```html
<div class="content">
    <%= yield %>
</div>
```

6. Add styles to `app/javascript/assets/adminlte.scss`:

```css
$fa-font-path: '~@fortawesome/fontawesome-free/webfonts';

@import '~@fortawesome/fontawesome-free/scss/fontawesome';
@import '~@fortawesome/fontawesome-free/scss/solid';
@import '~@fortawesome/fontawesome-free/scss/regular';
@import '~@fortawesome/fontawesome-free/scss/brands';

@import "~admin-lte/build/scss/adminlte";
```

7. Run tests and server to verify:

```bash
yarn test
bin/rails test
bin/rails test:system
bin/rails s
```

Expect to see:
![image](https://user-images.githubusercontent.com/53345298/80085750-586bc080-8561-11ea-8c3b-dc1eab5b9200.png)

## Configure continuous integration and other services for static code analysis.

To be able to automatically analyze the quality of the code, let's install the [jt_tools](https://github.com/jetthoughts/jt_tools) gem.

1. Add this line to your application's Gemfile:

```ruby
gem 'jt_tools', groups: [:development]
```

2. Next step is running bundle install and generator:

```bash
bin/bundle
bin/rails jt_tools:install
```

3. Run linters to verify

```bash
bin/lint-pr
```
You should see a list of the linters that were running.
