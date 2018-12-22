require 'bcrypt'

class User < ApplicationRecord
  before_create :assign_uid

  def groups
    return UserGroup.where('(access -> ?) is not null or owner_uid = ?', self.uid, self.uid)
  end

  def check_password(password)
    BCrypt::Password.new(encrypted_password) == password
  end
  def assign_uid
    self.uid = SecureRandom.hex(8)
  end
  def set_password(new_pass)
    self.encrypted_password = BCrypt::Password.create(new_pass)
  end

  def stats
    stats = {
      entries: Entry.where(owner_uid: self.uid).count,
      groups: UserGroup.where(owner_uid: self.uid).count
    }
    %w(_kanban _whiteboard _sheet).each do |cls|
      stats[cls] = Entry.where(owner_uid: self.uid).where('classes @> ARRAY[?]::varchar[]', cls).count
    end
    return stats
  end
end
