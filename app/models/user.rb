require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles


  validates_presence_of     :login
  validates_length_of       :login,       :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,       :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_presence_of     :email
  validates_length_of       :email,       :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,       :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  validates_format_of       :first_name,  :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_format_of       :last_name,   :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true

  validates_length_of       :first_name,  :maximum => 100, :allow_nil => true
  validates_length_of       :last_name,   :maximum => 100, :allow_nil => true
  

  

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :first_name, :last_name, :password, :password_confirmation



  # Authenticates a user by their login and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end


  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  protected
    
    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end


end