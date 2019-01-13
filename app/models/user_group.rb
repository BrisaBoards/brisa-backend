class UserGroup < ApplicationRecord
  VALID_ACCESS = %w(view comment edit admin)

  def share_json(uid, access)
    u = User.where(uid: uid).first
    return {uid: uid, access: access, user: u ? u.alias : nil}
  end
  def to_json
    json = { id: id, name: name, owner_uid: owner_uid,
      settings: settings, created_at: created_at, updated_at: updated_at }
    json[:access] = access.map do |k,v|
      share_json(k,v)
    end
    return json
  end

  def edit?(user)
    return true if user.uid == self.owner_uid
    return true if self.access[user.uid] == 'edit' or self.access[user.uid] == 'admin'
    return false
  end
  def comment?(user)
    return true if user.uid == self.owner_uid
    return true if self.edit?(user) or self.access[user.uid] == 'comment'
  end
  def view?(user)
    return true if user.uid == self.owner_uid
    return true if self.access[user.uid]
  end
  def admin?(user)
    return true if user.uid == self.owner_uid
    return true if self.access[user.uid] == 'admin'
    return false
  end
end
