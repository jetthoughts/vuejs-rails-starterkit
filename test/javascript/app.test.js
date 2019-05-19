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
