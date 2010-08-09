require 'spec_helper'

describe User do
  before(:each) do
    @attr = 
    {
      :name => "Example User",
      :email => "user@example.com"
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name = User.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end
  
  it "should require an email address" do
    no_email = User.new(@attr.merge(:email => ""))
    no_email.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long = "a" * 51
    user = User.new(@attr.merge(:name => long))
    user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      user = User.new(@attr.merge(:email => address))
      user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid = User.new(@attr.merge(:email => address))
      invalid.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given address into the database
    User.create!(@attr)
    dup = User.new(@attr)
    dup.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased))
    dup = User.new(@attr)
    dup.should_not be_valid
  end
end
