require 'spec_helper'

describe "Microposts" do
  before(:each) do
    @user = Factory(:user)
    integration_sign_in(@user)
  end
  
  describe "creation" do
    describe "failure" do
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector('div#error_explanation')
        end.should_not change(Micropost, :count)
      end
      
      it "should not change the micropost count" do
        visit root_path
        response.should have_selector('div.user_info', :content => '0 microposts')
        visit root_path
        fill_in :micropost_content, :with => ""
        click_button
        response.should render_template('pages/home')
        response.should have_selector('div#error_explanation')
        response.should have_selector('div.user_info', :content => '0 microposts')
      end
    end
    
    describe "success" do
      it "should make a new micropost" do
        content = "Lorem ipsum dolor sit amet"
        lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector('span.content', :content => content)
        end.should change(Micropost, :count).by(1)
      end
      
      it "should update the micropost count" do
        visit root_path
        response.should have_selector('div.user_info', :content => '0 microposts')
        content = "Lorem ipsum dolor sit amet"
        fill_in :micropost_content, :with => content
        click_button
        response.should have_selector('span.content', :content => content)
        response.should have_selector('div.user_info', :content => '1 micropost')
        content = "Lorem ipsum 2"
        fill_in :micropost_content, :with => content
        click_button
        response.should have_selector('span.content', :content => content)
        response.should have_selector('div.user_info', :content => '2 microposts')
      end
    end
  end
  
  describe "home page" do
    before(:each) do
      @other_user = Factory(:user, :email => Factory.next(:email))
      @micropost = Factory(:micropost, :user => @other_user)
    end
    
    it "should not show delete for other users' microposts" do
      visit user_path(@other_user)
      response.should have_selector('span.content', :content => @micropost.content)
      response.should_not have_selector('a', :content => 'delete')
    end
    
    it "should have a delete link for own microposts" do
      visit root_path
      content = "Lorem ipsum dolor sit amet"
      fill_in :micropost_content, :with => content
      click_button      
      visit user_path(@user)
      response.should have_selector('span.content', :content => content)
      response.should have_selector('a', :content => 'delete')
    end
    
    it "should paginate microposts" do
      60.times do
        Factory(:micropost, :user => @user)
      end

      visit root_path
      response.should have_selector('div.pagination')
      response.should have_selector('span.disabled', :content => 'Previous')
      response.should have_selector('a', :href => '/?page=2',
                                         :content => '2')
      response.should have_selector('a', :href => '/?page=2',
                                         :content => 'Next')
    end
  end
end
