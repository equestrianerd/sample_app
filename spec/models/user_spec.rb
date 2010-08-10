require 'spec_helper'

describe User do
  before(:each) do
    @attr = 
    {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
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
  
  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      it "should be true if passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        wrong = User.authenticate(@attr[:email], "wrongpass")
        wrong.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        nonexist = User.authenticate("bar@foo.com", @attr[:password])
        nonexist.should be_nil
      end
      
      it "should return the user on email/password match" do
        match = User.authenticate(@attr[:email], @attr[:password])
        match.should == @user
      end
    end
  end
end
