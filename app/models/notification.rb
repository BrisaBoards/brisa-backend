class Notification < ApplicationRecord
  belongs_to :user
  def ws_message(action, session_id=nil)
    msg = {
      m: 'notify',
      a: action,
      id: self.id,
    }
    msg[:sid] = session_id if session_id
    return msg
  end

  def broadcast(action, session_id=nil)
    msg = self.ws_message(action, session_id)
    ActionCable.server.broadcast("user_#{user.uid}", msg)
  end
end
