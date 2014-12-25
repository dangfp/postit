class User < ActiveRecord::Base
  include Sluggable

  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validations: false
  validates :username, presence: true, uniqueness: true, length: {minimum: 6}
  validates :password, presence: true, on: :create, length: {minimum: 6}

  sluggable_column :username

  def generate_pin!
    self.update(pin: rand(10 ** 6))
  end

  def remove_pin!
    self.update(pin: nil)
  end

  def send_pin_to_twilio
    msg = "Please enter your pin number: #{self.pin}"
    # put your own credentials here
    account_sid = 'AC5ad654c835f49472fd7ed8ff6db94d6b'
    auth_token = '224164e6c6d0b3798a1fa294ad171766'

    # set up a client to talk to the Twilio REST API
    client = Twilio::REST::Client.new account_sid, auth_token

    client.account.messages.create({
      :from => '+12013832952',
      :body => msg,
      :to => self.phone,
    })
  end

  def two_factor_auth?
    self.phone.present?
  end

  def admin?
    self.role == 'admin'
  end
end