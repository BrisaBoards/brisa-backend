require 'bcrypt'

class User < ApplicationRecord
  before_create :assign_uid

  def check_password(password)
    BCrypt::Password.new(encrypted_password) == password
  end
  def assign_uid
    self.uid = SecureRandom.hex(8)
  end
  def set_password(new_pass)
    self.encrypted_password = BCrypt::Password.create(new_pass)
  end
end
