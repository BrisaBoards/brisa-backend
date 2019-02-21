load './lib/brisa_notifier.rb'

class BrisaComment < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Comment', attrs: %w(user_uid comment metadata reply_to)

  api_action 'all', args: %w(entry_id), returns: ['Comment']
  api_action 'find', args: %w(id), returns: 'Comment'
  api_action 'create', args: %w(data), returns: 'Comment'
  api_action 'destroy', args: %w(id), instance: :id, returns: 'Comment'
  api_action 'update', args: %w(id data), instance: :id, include_data: :data, returns: :self

  def self.all(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    entry = Entry.find(params[:entry_id])
    raise BrisaApiError.new('Access denied') unless entry.view?(user)
    return Comment.where(entry_id: params[:entry_id]).order(created_at: :asc).map(&:to_api)
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    data = params[:data]
    entry = Entry.find(data[:entry_id])
    raise BrisaApiError.new('Access denied') unless entry.comment?(user)
    comment = Comment.create!(user_uid: user.uid, entry_id: entry.id, comment: data[:comment],
        reply_to: data[:reply_to])
    BrisaNotifier.EntryComment(entry.user_group, user, !data[:is_role], entry, comment, data[:ctx])
    comment.broadcast(:create, params[:sid])
    comment.to_api
  end

  def self.update(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    comment = Comment.find(params[:id])
    raise BrisaApiError.new('Access denied') unless comment.user_uid == user.uid
    data = params.require(:data)
    comment.update!(comment: data[:comment])
    comment.broadcast(:update, params[:sid])
    comment.to_api
  end

  def self.find(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    comment = Comment.find(params[:id])
    raise BrisaApiError.new('Access denied') unless comment.entry.view?(user)
    comment.to_api
  end

  def self.destroy(params, user, ctx)
    raise BriaApiError.new('Access denied') unless user
    comment = Comment.find(params[:id])
    raise BrisaApiError.new('Access denied') unless comment.user_uid == user.uid
    # TODO: If other comments match entry_id and reply_to == 'comment.<id>',
    # mark as deleted and clear data so there's a placeholder.
    comment.broadcast(:destroy, params[:sid])
    comment.destroy
    comment.to_api
  end

end
