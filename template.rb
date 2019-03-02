require "fileutils"
require "shellwords"

def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("jumpstart-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
        "--quiet",
        "https://github.com/jetthoughts/vuejs-rails-5-starterkit.git",
        tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{vuejs-rails-5-starterkit/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def add_gems
  gsub_file 'Gemfile', /gem 'webpacker'/, "gem 'webpacker', '>= 4.0.x'"
end

def set_application_name
  environment "config.application_name = Rails.application.class.parent_name"
end

def stop_spring
  run "spring stop"
end

def add_webpack
  run 'bundle update webpacker'

  run "echo 'Y' | rails webpacker:install"
  run 'rails webpacker:install:vue'

  run 'yarn add @rails/webpacker@next'
  run 'yarn upgrade webpack-dev-server --latest'
  run'yarn install'
end

def setup_application
  rails_command 'db:create'
  rails_command 'db:migrate'

  uncomment_lines 'bin/setup', /bin\/yarn/
  uncomment_lines 'bin/update', /bin\/yarn/

  run 'bin/setup'
end

def enable_unsafe_eval
  content = <<-RUBY
    Rails.application.config.content_security_policy do |policy|
      if Rails.env.development?
        policy.script_src :self, :https, :unsafe_eval
        policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035'
      else
        policy.script_src :self, :https
      end
    end
  RUBY

  insert_into_file 'config/initializers/content_security_policy.rb',
                   "\n" + content + "\n",
                   after: 'Be sure to restart your server when you modify this file.'
end

def setup_babelrc
  run 'yarn add @vue/babel-preset-app'

  content = <<-JS
    {
      "presets": [
        [
          "@vue/app",
          {
            "modules": false,
            "forceAllTransforms": true,
            "useBuiltIns": "entry"
          }
        ]
      ],
      "env": {
        "test": {
          "presets": [
            ["@babel/preset-env", {
              "targets": {
                "node": "current"
              }
            }]
          ]
        }
      },
      "plugins": [
        "@babel/plugin-transform-destructuring",
        "@babel/plugin-syntax-dynamic-import",
        [
          "@babel/plugin-proposal-object-rest-spread",
          {
            "useBuiltIns": true
          }
        ],
        [
          "@babel/plugin-transform-runtime",
          {
            "helpers": false,
            "regenerator": true
          }
        ],
        [
          "@babel/plugin-transform-regenerator",
          {
            "async": false
          }
        ],
        [
          "@babel/plugin-proposal-class-properties",
          {
            "loose": true
          }
        ]
      ]
    }
  JS

  create_file '.babelrc', content
end

def include_vue_files
  gsub_file 'app/views/layouts/application.html.erb', /application/, 'hello_vue'
  gsub_file 'app/views/layouts/application.html.erb', /stylesheet_link_tag/, 'stylesheet_pack_tag'
  gsub_file 'app/views/layouts/application.html.erb', /javascript_include_tag/, 'javascript_pack_tag'
end

def generate_hello_controller
  rails_command 'generate controller Landing index --no-javascripts'\
                ' --no-stylesheets --no-helper --no-assets --no-fixture'

  route "root 'landing#index'"
end

def add_jest_library
  run "yarn add --dev jest vue-jest babel-jest @vue/test-utils jest-serializer-vue 'babel-core@^7.0.0-bridge' @babel/core"

  content = <<-JSON
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
        "^.+(js)$": "<rootDir>/node_modules/babel-jest",
        ".*(vue)$": "<rootDir>/node_modules/vue-jest"
      },
      "snapshotSerializers": [
        "<rootDir>/node_modules/jest-serializer-vue"
      ]
    },
  JSON

  insert_into_file 'package.json', "\n" + content, after: /^{/
end

def add_jest_test
  content = <<-JS
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
  JS

  create_file 'test/javascript/app.test.js', content
end

def run_tests
  run 'DISABLE_SPRING=1 bin/rails test'
  run 'yarn test'

  run 'DISABLE_SPRING=1 bin/rails server & sleep 5'
  run 'xdg-open http://localhost:3000'
end

### Main setup ###

add_template_repository_to_source_path
add_gems

setup_application

after_bundle do
  set_application_name
  stop_spring
  add_webpack
  enable_unsafe_eval
  setup_babelrc
  include_vue_files
  generate_hello_controller

  add_jest_library
  add_jest_test

  run_tests

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }

  say
  say "Jumpstart app successfully created! 🙌", :blue
  say

  say "To get started with your new app:", :green
  say "cd #{app_name} - Switch to your new app's directory."

  say "rails test - Run Rails tests"
  say "yarn test - Run Jest tests"
  say "rails server - Run Rails application"
end
