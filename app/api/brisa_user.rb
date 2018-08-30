class BrisaUser < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'User'

  api_action 'status', args: %w()
  api_action 'login', args: %w(username, password)
  api_action 'logout', args: %w()

  def self.status(params, user, ctx)
    if user
      return { id: user.id, alias: user.alias, email: user.email, admin: user.admin, logged_in: true }
    end
    return { logged_in: false}
  end

  def self.login(params, user, ctx)
    if u = User.where(email: params[:email]).first
      if BCrypt::Password.new(u.encrypted_password) == params[:password]
        if u.disabled?
          raise BrisaApiError.new((u.disabled_message || '').empty? ? 'Account Disabled' : u.disabled_message)
        end
        ctx.session[:user_id] = u.id
        return self.status({}, u, ctx)
      end
    end
    raise BrisaApiError.new("Invalid e-mail or password")
  end

  def self.logout(params, user, ctx)
    ctx.session.destroy
    return self.status(params, nil, ctx)
  end
end
