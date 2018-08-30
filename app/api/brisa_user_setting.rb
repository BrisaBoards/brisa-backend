class BrisaUserSetting < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'UserSetting'

  api_action 'all', args: %w()
  api_action 'create', args: %w()
  api_action 'update', args: %w(id name setting)
  api_action 'destroy', args: %w(id)

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    UserSetting.where(user_id: user.id)
  end

  def self.update(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    setting = UserSetting.where(id: params['id'], user_id: user.id).first
    setting.update!(name: params[:data][:name], setting: params[:data][:setting])
    setting
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    setting = UserSetting.where(name: params[:name], user_id: user.id).first
    if setting.nil?
      setting = UserSetting.create!(user_id: user.id, name: params['name'], setting: params['setting'])
    end
    setting
  end

  def self.destroy(params, user, ctx)
    setting = UserSetting.where(id: params['id'], user_id: user.id).first
    setting.destroy
    setting
  end
end
