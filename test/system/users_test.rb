require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  include BootstrapSelectHelper
  setup do
    @admin = users(:one)
    @user = users(:three)
  end

  test 'admin visits the index' do
    login_as @admin
    visit users_path
    assert_selector 'h1', text: 'Users'
    assert page.has_css?('table tbody tr', count: 3)
  end

  test "admin updates user's attributes" do
    assert_equal @user.email_preference, 'No Emails'
    login_as @admin
    visit edit_user_path(@user)
    bootstrap_select('Comments and Digest', from: 'user_email_preference')
    click_button 'Save'
    assert_selector 'table tbody tr td', text: 'Comments and Digest'
    assert_equal @user.reload.email_preference, 'Comments and Digest'
  end

  test 'user updates their own email preference' do
    assert_equal @user.email_preference, 'No Emails'
    login_as @user
    visit edit_user_path(@user)
    bootstrap_select('Comments and Digest', from: 'user_email_preference')
    click_button 'Save'
    assert_equal @user.reload.email_preference, 'Comments and Digest'
  end

  test 'admin updates user departments' do
    assert_equal @user.departments, []
    login_as @admin
    visit edit_user_path(@user)
    bootstrap_multi_select('CRIM', 'SINT', from: 'user_departments')
    click_button 'Save'
    assert_selector 'table tbody tr td', text: 'CRIM, SINT'
    assert_equal @user.reload.departments, ['CRIM', 'SINT']
  end

  test 'user updates their departments' do
    assert_equal @user.departments, []
    login_as @user
    visit edit_user_path(@user)
    bootstrap_multi_select('CRIM', 'SINT', from: 'user_departments')
    click_button 'Save'
    assert_equal @user.reload.departments, ['CRIM', 'SINT']
  end
end
