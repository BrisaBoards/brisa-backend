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
        local_file = Rails.root.join('last_update.msg.local')
        global_file = Rails.root.join('last_update.msg')
        local_up = JSON.parse(File.open(local_file).read) if File.exists?(local_file)
        global_up = JSON.parse(File.open(global_file).read) if File.exists?(global_file)
        if !local_up.nil? and local_up['s'] >= global_up['s']
          @@update_message = local_up
        else
          @@update_message = global_up
        end
      end
    rescue => e
      logger.error(e)
    end

    return @@update_message || {}
  end
end
