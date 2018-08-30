require 'bcrypt'

class User < ApplicationRecord

  def set_password(new_pass)
    self.encrypted_password = BCrypt::Password.create(new_pass)
  end
end
