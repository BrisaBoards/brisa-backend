class Entry < ApplicationRecord
  belongs_to :user_group, foreign_key: :group_id, optional: true
  def edit?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.edit?(user)
    return false
  end
  def view?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.view?(user)
    return false
  end
  def comment?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.view?(user)
    return false
  end
  def admin?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.admin?(user)
    return false
  end
end
