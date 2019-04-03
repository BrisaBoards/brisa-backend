class Comment < ApplicationRecord
  belongs_to :entry

  def to_api
    return {
      id: self.id,
      user: User.where(uid: self.user_uid).map { |u| u.alias }.first,
      user_uid: self.user_uid,
      comment: self.comment,
      created_at: self.created_at,
      updated_at: self.updated_at,
    }
  end

  def ws_message(action, session_id=nil)
    msg = {
      m: 'cmt',
      a: action,
      gid: self.entry.group_id,
      id: self.entry_id,
      cmt: self.id,
    }
    msg[:sid] = session_id if session_id
    return msg
  end

  def broadcast(action, session_id=nil)
    msg = self.ws_message(action, session_id)
    self.entry.user_uids.each do |uid|
      ActionCable.server.broadcast("user_#{uid}", msg)
    end
  end

end
