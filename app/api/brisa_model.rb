class BrisaModel < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Model', attrs: %w(owner_uid group_id unique_id title config)

  api_action 'all', args: %w(group_id), returns: ['Model']
  api_action 'create', args: %w(data), returns: 'Model'
  api_action 'update', args: %w(id data), instance: :id, include_data: :data, returns: :self

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    if params[:group_id]
      group = UserGroup.where(id: params[:group_id]).first
      raise BrisaApiError.new('Group not found') unless group
      raise BrisaApiError.new('Access denied') unless group.view?(user)
      return UserModel.where(group_id: group.id)
    end
    return UserModel.where(owner_uid: user.uid, group_id: nil)
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    data = params.require(:data)
    if data[:group_id]
      group = UserGroup.where(id: data[:group_id]).first
      raise BrisaApiError.new('Group not found') unless group
      raise BrisaApiError.new('Access denied') unless group.edit?(user)
    end
    UserModel.create!(group_id: data[:group_id], owner_uid: user.uid, config: data[:config] || {},
      title: data[:title], unique_id: data[:unique_id])
  end

  def self.update(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    model = UserModel.find(params[:id])
    if model.group_id
      group = UserGroup.where(id: model.group_id).first
      raise BrisaApiError.new('Group not found') unless group
      raise BrisaApiError.new('Access denied') unless group.edit?(user)
    else
      raise BrisaApiError.new('Access denied') unless model.owner_uid == user.uid
    end
    data = params.require(:data)
    model.update!(config: data[:config], title: data[:title], unique_id: data[:unique_id])
    model
  end
end
