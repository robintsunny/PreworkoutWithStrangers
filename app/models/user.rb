# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  fname           :string
#  email           :string
#  home_city_id    :integer          not null
#

class User < ApplicationRecord

  validates :email, :session_token, :password_digest, presence: true
  validates :email, :session_token, uniqueness: true
  validates :password, length: {minimum: 8, allow_nil: true}
  before_validation :ensure_session_token
  attr_reader :password
  # validates :joined_events, length: {maximum: 3}

  belongs_to :hometown, {
    primary_key: :id,
    foreign_key: :home_city_id,
    class_name: :City
  }
  #
    has_many :hosted_events, {
    primary_key: :id,
    foreign_key: :host_id,
    class_name: :Event
  }

  has_many :rsvps, {
      primary_key: :id,
      foreign_key: :user_id,
      class_name: :Rsvp
  }

  has_many :joined_events, {
    through: :rsvps,
    source: :event
  }

  # def joined_events_count
  #   self.joined_events.count
  # end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(pw)
    BCrypt::Password.new(self.password_digest).is_password?(pw)
  end

  def self.find_by_cred(email,pw)
    user = User.find_by(email: email)
    user && user.is_password?(pw) ? user : nil
  end

  def reset_session_token!
    self.session_token =  SecureRandom.urlsafe_base64
    self.save!
    self.session_token
  end

  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64
  end
end
