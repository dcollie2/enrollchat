require 'test_helper'

class SignInTest < ActionDispatch::IntegrationTest
  test 'should send users who are not signed in to login page' do
    get sections_url
    assert_response :success
    assert_select "input#username"
    assert_select "input#password"
  end

  test 'should send users who are not signed in and try to access an admin only page to the login page' do
    get users_url
    assert_response :success
    assert_select "input#username"
    assert_select "input#password"
  end

  test 'should allow successfully signed in users to reach main sections page' do
    login_as(users(:two))
    get sections_url
    assert_response :success
    assert_select 'a', 'Filter'
  end

  test 'should send users who are already signed in to main sections page as the authenticated root' do
    login_as(users(:two))
    get '/'
    assert_redirected_to sections_url
  end

  test 'should send unregistered users to unregistered page' do
    unregistered_login
    get sections_url
    assert_redirected_to unregistered_url
  end
end
