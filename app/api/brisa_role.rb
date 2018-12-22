class BrisaRole < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Role', attrs: %w(name)

  api_action 'create', args: %w(name password), returns: 'Role'
  api_action 'all', args: %w(), returns: ['Role']
  api_action 'destroy', args: %w(id), instance: :id, returns: :data
  api_action 'token', args: %w(id password exp), instance: :id, returns: :data

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    raise BrisaApiError.new('Invalid password') unless user.check_password(params[:password])
    role = Role.create(user_id: user.id, name: params[:name])
    role
  end

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    return Role.where(user_id: user.id)
  end

  def self.destroy(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    role = Role.where(id: params[:id]).first
    raise BrisaApiError.new('Role not found') unless role
    raise BrisaApiError.new('Access denied') unless role.user_id == user.user_id
    role.destroy
    true
  end

  def self.token(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    role = Role.where(id: params[:id]).first
    raise BrisaApiError.new('Role not found') unless role
    raise BrisaApiError.new('Access denied') unless role.user_id == user.id
    raise BrisaApiError.new('Access denied') unless user.check_password(params[:password])
    exp = params[:exp].nil? ? nil : Time.parse(params[:exp])
    return { auth_token: BrisaJWT.create_token(role.id, params[:exp], true) }
  end
end
