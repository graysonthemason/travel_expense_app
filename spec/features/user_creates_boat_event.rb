require 'rails_helper'

# User.destroy_all

# describe "the signin process", :type => :feature do
#   before :each do
#     User.make(:email => 'user@example.com', :password => 'caplin')
#   end
#
#   it "signs me in" do
#     visit '/sessions/new'
#     within("#session") do
#       fill_in 'Email', :with => 'user@example.com'
#       fill_in 'Password', :with => 'password'
#     end
#     click_button 'Sign in'
#     expect(page).to have_content 'Success'
#   end
# end

describe 'User creates boat trip' do
  it 'can signup/create profile' do
    visit root_path

    click_link 'Sign up'
    expect(page).to have_css '.new_user'
    fill_in 'Email', :with => 'user@example.com'
    fill_in 'Name', :with => 'will'
    fill_in 'Password', :with => 'guest'
    fill_in 'Confirmation', :with => 'guest'
    click_button 'Create User'
    expect(page).to have_content 'will'
  end
end
