require 'openssl'

class User < ApplicationRecord
  
  ITERATIONS = 20_000
  DIGEST = OpenSSL::Digest::SHA256.new

  has_many :quesrtions
  FORMAT_USER = /[a-z\d_]+/i
  validates :username, presence: true, uniqueness: true, length: {maximum: 40}, format: {with: FORMAT_USER}
  FORMAT_EMAIL = /[a-z\d+_.\-]+@[a-z\d\-]+([a-z\d.\-]+)*\.[a-z]+/i
  validates :email, presence: true, uniqueness: true, format: {with: FORMAT_EMAIL}

  attr_accessor :password

  validates :password, presence: true, on: :create
  validates_confirmation_of :password

  before_save :encrypt_password
  before_validation :downcase_username

  def downcase_username
    username.downcase!
  end

  def encrypt_password
    if password.present?
      self.password_salt = User.hash_to_string(OpenSSL::Random.random_bytes(16))

      self.password_hash = User.hash_to_string(
        OpenSSL::PKCS5.pbkdf2_hmac(
          password, password_salt, ITERATIONS, DIGEST.length, DIGEST
        )
      )
    end
  end
  def self.hash_to_string(password_hash)
    password_hash.unpack('H*')[0]
  end

  def self.authenticate(email, password)
    user = find_by(email: email)

    return nil unless user.present?

    hashed_password = User.hash_to_string(
      OpenSSL::PKCS5.pbkdf2_hmac(
        password, user.password_salt, ITERATIONS, DIGEST.length, DIGEST
      )
    )

    return user if user.password_hash == hashed_password

    nil
  end
end
