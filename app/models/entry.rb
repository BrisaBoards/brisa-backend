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
    return true if self.user_group and self.user_group.comment?(user)
    return false
  end
  def admin?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.admin?(user)
    return false
  end

  def user_uids
    if self.group_id.nil?
      return [self.owner_uid]
    end

    return ([self.owner_uid] + self.user_group.access.keys).uniq
  end

  def ws_message(action, session_id=nil)
    msg = {
      m: 'ent',
      a: action,
      gid: self.group_id,
      id: self.id,
      tags: self.tags,
      classes: self.classes
    }
    msg[:sid] = session_id if session_id
    return msg
  end

  def broadcast(action, session_id=nil)
    msg = self.ws_message(action, session_id)
    user_uids.each do |uid|
      ActionCable.server.broadcast("user_#{uid}", msg)
    end
  end
end
