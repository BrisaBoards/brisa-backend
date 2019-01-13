class BrisaUser < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'User', attrs: %w(alias admin)

  api_action 'status', args: %w(renew)
  api_action 'update_account', args: %w(alias)
  api_action 'change_pass', args: %w(password new_password)
  api_action 'login', args: %w(email password), returns: 'User'
  api_action 'groups', args: %w(), returns: ['Group']
  api_action 'logout', args: %w()

  def self.update_account(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    user.update(alias: params[:alias])
    return true
  end

  def self.change_pass(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    raise BrisaApiError.new('Current password does not match.') unless user.check_password(params[:password])
    user.set_password(params[:new_password])
    user.save
    return true
  end

  def self.groups(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    (UserGroup.where(owner_uid: user.uid) +
      UserGroup.where("access -> ? is not null", user.uid.to_s)).map &:to_json
  end

  def self.status(params, user, ctx)
    token =  params[:auth_token]
    if user
      result = { id: user.id, uid: user.uid, alias: user.alias, email: user.email, admin: user.admin, logged_in: true }
      if params[:renew]
        result['auth_token'] = BrisaJWT.create_token(user.id)
      end
      return result
    end
    return { logged_in: false}
  end

  def self.login(params, user, ctx)
    # TODO: Add rate limiting by IP and e-mail.
    if u = User.where(email: params[:email]).first
      if u.check_password(params[:password])
        if u.disabled?
          raise BrisaApiError.new((u.disabled_message || '').empty? ? 'Account Disabled' : u.disabled_message)
        end
        token = BrisaJWT.create_token(u.id)
        return self.status({}, u, ctx).merge({auth_token: token})
      end
    end
    raise BrisaApiError.new("Invalid e-mail or password")
  end

  def self.logout(params, user, ctx)
    ctx.session.destroy
    return self.status(params, nil, ctx)
  end
end
