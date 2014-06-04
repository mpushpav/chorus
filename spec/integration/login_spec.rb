require File.join(File.dirname(__FILE__), 'spec_helper')

describe "login tests" do

  before do
    login(users(:admin))
    visit "/#/users/new"
    fill_in 'firstName', :with => "new"
    fill_in 'lastName', :with => "person"
    fill_in 'username', :with => "new_user"
    fill_in 'email', :with => "new_user@example.com"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'title', :with => "dev"
    fill_in 'dept', :with => "chorus"
    fill_in 'notes', :with => "This is a test user."
    click_button "Add This User"

    within ".main_content" do
      click_link "new person"
      find("h1").should have_content("new person")
    end
    logout
  end

  it "logs in with the valid username and password" do
    visit("/#/login")
    page.should have_selector("form.login")
    fill_in 'username', :with => "new_user"
    fill_in 'password', :with => "secret"
    click_button "Login"
    page.should have_content("new person")
  end

  it "logs in with wrong username and password" do
    visit("/#/login")
    page.should have_selector("form.login")
    fill_in 'username', :with => "newuser"
    fill_in 'password', :with => "secret"
    click_button "Login"
    page.should have_content("Username or password is invalid")
    page.find("li", :text => "Username or password is invalid")
  end

  it "logs in with valid username and wrong password" do
    visit("/#/login")
    page.should have_selector("form.login")
    fill_in 'username', :with => "new_user"
    fill_in 'password', :with => "secret12345"
    click_button "Login"
    page.should have_content("Username or password is invalid")
    page.find("li", :text => "Username or password is invalid")
  end

  it "logs in with invalid username and password" do
    visit("/#/login")
    page.should have_selector("form.login")
    fill_in 'username', :with => "new_user"
    fill_in 'password', :with => "secret12345"
    click_button "Login"
    page.should have_content("Username or password is invalid")
    page.find("li", :text => "Username or password is invalid")
  end
end