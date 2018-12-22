module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :auth_token

    def connect
      self.auth_token = @request.params[:auth_token]
    end

  end
end
