class UserChannel < ApplicationCable::Channel
  def subscribed
    user = BrisaJWT.check_token(connection.auth_token)
    if !user
      reject
      return
    end
    stream_from "user_#{user.uid}"
    connection.transmit({identifier: '{"channel":"UserChannel"}', message: {m: 'sid', sid: SecureRandom.alphanumeric(8)}})
  end
end
