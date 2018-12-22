class BrisaJWT
  @@secret_key_base = nil

  def self.secret_key
    @@secret_key_base ||= Rails.application.credentials.secret_key_base
    @@secret_key_base
  end

  def self.create_token(token_id, exp=2.days.from_now, is_role=false)
    token_info = is_role ? {rol: token_id} : {user_id: token_id}
    token_info[:exp] = exp.to_i unless is_role and exp.nil?
    return JWT.encode(token_info, secret_key)
  end

  def self.check_token(token)
    begin
      token_data = JWT.decode(token, secret_key)[0]
      if token_data['user_id']
        return User.where(id: token_data['user_id']).first
      elsif token_data['rol']
        role = Role.where(id: token_data['rol']).first
        return User.where(id: role.user_id).first if role
      end
    rescue StandardError => e
      puts e
    end
    return nil
  end
end
