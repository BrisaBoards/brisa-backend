class BrisaGroup < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Group', attrs: %w(name id settings owner_uid access)

  api_action 'create', args: %w(name), returns: 'Group'
  api_action 'find', args: %w(id), instance: :id, returns: :self
  api_action 'add_share', args: %w(id email access), instance: :id, returns: :self
  api_action 'remove_share', args: %w(id email), instance: :id, returns: :data
  api_action 'shares', args: %w(id), instance: :id, returns: :data
  api_action 'setting', args: %w(id name value), instance: :id, returns: :data

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    UserGroup.create(name: params[:name], owner_uid: user.uid, access: {}, settings: {})
  end

  def self.find(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    group = UserGroup.find(params[:id])
    raise BrisaApiError.new('Access denied') unless group.view?(user)
    group.to_json
  end

  def self.add_share(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    raise BrisaApiError.new('Invalid access type ' + params[:access]) unless UserGroup::VALID_ACCESS.include?(params[:access])
    group = UserGroup.find(params[:id])
    raise BrisaApiError.new('Access denied') unless group.admin?(user)
    new_user = User.where(email: params[:email]).first
    raise BrisaApiError.new('E-Mail not found') unless new_user
    group.access[new_user.uid] = params[:access]
    group.save!
    return group.to_json
  end

  def self.remove_share(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
  end

  def self.shares(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
  end

  def self.setting(params, user, ctx)
    params[:value]
  end
end
