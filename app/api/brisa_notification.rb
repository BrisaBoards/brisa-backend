class BrisaNotification < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Notification', attrs: %w(user_id parent ctx messages read)

  api_action 'all', args: %w(), returns: ['Notification']
  api_action 'find', args: %w(id), instance: :id, returns: :self
  api_action 'mark_read', args: %w(id), instance: :id, returns: :data
  api_action 'destroy', args: %w(id), instance: :id, returns: 'Notification'

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    return Notification.where(user_id: user.id).order(updated_at: :desc)
  end

  def self.find(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    note = Notification.where(user_id: user.id, id: params[:id]).first
    raise BrisaApiError.new('Not found') unless note
    note
  end

  def self.mark_read(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    note = Notification.where(user_id: user.id, id: params[:id]).first
    raise BrisaApiError.new('Not found') unless note
    note.update_column(:is_read, true)
    true
  end

  def self.destroy(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    note = Notification.where(user_id: user.id, id: params[:id]).first
    raise BrisaApiError.new('Not found') unless note
    note.broadcast(:destroy, params[:sid])
    note.destroy
    note
  end

end
