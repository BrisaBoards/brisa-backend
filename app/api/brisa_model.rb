class BrisaModel < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Model', attrs: %w(unique_id title config)

  api_action 'all', args: %w(), returns: ['Model']
  api_action 'create', args: %w(data), returns: 'Model'
  api_action 'update', args: %w(id data), instance: :id, include_data: :data, returns: :self

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    UserModel.where(owner_id: user.id)
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    data = params.require(:data)
    UserModel.create!(owner_id: user.id, config: data[:config] || {},
      title: data[:title], unique_id: data[:unique_id])
  end

  def self.update(params, user, ctx)
    model = UserModel.find(params[:id])
    raise BrisaApiError.new('Access denied') unless model.owner_id == user.id
    data = params.require(:data)
    model.update!(config: data[:config], title: data[:title], unique_id: data[:unique_id])
    model
  end
end
