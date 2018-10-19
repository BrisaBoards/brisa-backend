class BrisaUser < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'User', attrs: %w(alias admin)

  api_action 'status', args: %w(renew)
  api_action 'login', args: %w(email password), returns: 'User'
  api_action 'groups', args: %w(), returns: ['Group']
  api_action 'logout', args: %w()

  def self.groups(params, user, ctx)
    raise BrisaAPIError.new('Access denied') unless user
    (UserGroup.where(owner_uid: user.uid) +
      UserGroup.where("access -> ? is not null", user.uid.to_s)).map &:to_json
  end

  def self.status(params, user, ctx)
    token =  params[:auth_token]
    if user
      if params[:renew]
        token = create_token(user.id)
      end
      return { id: user.id, uid: user.uid, alias: user.alias, email: user.email, admin: user.admin, logged_in: true, auth_token: token }
    end
    return { logged_in: false}
  end

  def self.login(params, user, ctx)
    if u = User.where(email: params[:email]).first
      if BCrypt::Password.new(u.encrypted_password) == params[:password]
        if u.disabled?
          raise BrisaApiError.new((u.disabled_message || '').empty? ? 'Account Disabled' : u.disabled_message)
        end
        token = create_token(u.id)
        puts "Encode token with #{Rails.application.credentials.secret_key_base}"
        #ctx.session[:user_id] = u.id
        return self.status({}, u, ctx).merge({auth_token: token})
      end
    end
    raise BrisaApiError.new("Invalid e-mail or password")
  end

  def self.logout(params, user, ctx)
    ctx.session.destroy
    return self.status(params, nil, ctx)
  end

  def self.create_token(user_id, exp=1.day.from_now)
    token_info = {user_id: user_id}
    token_info[:exp] = exp.to_i
    return JWT.encode(token_info, Rails.application.credentials.secret_key_base)
  end
end
