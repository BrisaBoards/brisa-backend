class UserChannel < ApplicationCable::Channel

  def subscribed
    user = BrisaJWT.check_token(connection.auth_token)
    if !user
      reject
      return
    end
    stream_from "user_#{user.uid}"
    connection.transmit({identifier: '{"channel":"UserChannel"}', message: {m: 'sid', sid: SecureRandom.alphanumeric(8)}})
    connection.transmit({identifier: '{"channel":"UserChannel"}', message: get_update() })
  end

  def get_update
    @@update_message ||= nil
    begin
      if @@update_message.nil?
        @@update_message = JSON.parse(File.open(Rails.root.join('last_update.msg')).read)
      end
    rescue => e
    end

    return @@update_message || {}
  end
end
