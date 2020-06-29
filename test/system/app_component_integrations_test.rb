require 'application_system_test_case'

class AppComponentIntegrationsTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome

  test 'vue component on landing page' do
    visit root_path

    assert_selector 'p', text: 'Hello Vue!'
  end
end
