load './lib/brisa_notifier.rb'

class BrisaEntry < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Entry', attrs: %w(title group_id owner_uid creator_uid description
      metadata tags classes created_at updated_at comment_count),
      desc: ""

  api_action 'find', args: %w(id), returns: :self, instance: :id, desc: "Find an entry by id."
  api_action 'updates', args: %w(since), returns: :data, desc: "List all changes after a specified time."
  api_action 'search', args: %w(tags classes group_id), returns: ['Entry'], desc: "Search for entries matching a set of tags and classes within a group."
  api_action 'create', args: %w(data), returns: 'Entry', desc: "Create a new entry."
  api_action 'update', args: %w(id data), instance: :id, include_data: :data, returns: :self, desc: "Update all entry data."
  api_action 'partial', args: %w(id actions), returns: :self, instance: :id, desc: "Perform actions to make partial entry edits."
  api_action 'assign', args: %w(id uid assign ctx is_role), instance: :id, returns: :data, desc: "Add or remove assignee."
  api_action 'watch', args: %w(id watch), instance: :id, returns: :data, desc: "Watch (or unwatch) entry."
  api_action 'add_tags', args: %w(id tags), instance: :id, returns: :self, desc: "Add a tag (or tags) to an entry."
  api_action 'remove_tags', args: %w(id tags), instance: :id, returns: :self, desc: "Remove a tag (or tags) from an entry."
  api_action 'edit_class', args: %w(id class_name cfg), instance: :id, returns: :self, desc: "Add (or update) a class and associated metadata."
  api_action 'destroy', args: %w(id), instance: :id, desc: "Delete entry."

  def self.assign(params, user, ctx)
    entry = Entry.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    # uid assign
    if params[:assign]
      if !entry.assignees.include?(params[:uid])
        entry.assignees.push params[:uid]
        BrisaNotifier.EntryAssigned(entry, user, params[:uid], true, !params[:is_role], params[:ctx])
        entry.save
      end
    else
      if entry.assignees.delete(params[:uid])
        BrisaNotifier.EntryAssigned(entry, user, params[:uid], false, !params[:is_role], params[:ctx])
        entry.save
      end
    end
    entry.broadcast(:update, params[:sid])
    true
  end

  def self.watch(params, user, ctx)
    entry = Entry.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.view?(user)
    # watch
    if params[:watch]
      if !entry.watchers.include?(user.uid)
        entry.watchers.push user.uid
        entry.save
      end
    else
      entry.save if entry.watchers.delete user.uid
    end
    true
  end

  def self.find(params, user, ctx)
    entry = Entry.comment_counts.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    entry
  end

  def self.updates(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    begin
      stamp = Time.at(params[:since].to_i)
    rescue
      raise BrisaApiError.new('Timestamp not recognized')
    end
    where_args = [user.uid]
    where = "(owner_uid = ? and group_id is null)"
    user.groups.each do |group|
      where += 'or group_id = ?'
      where_args.push group.id
    end
    entries = Entry.where(where, *where_args).where('created_at >= ? or updated_at >= ?', stamp, stamp).select(:id, :group_id, :created_at, :updated_at, :tags, :classes)
    return entries.map {|e| e.ws_message(e.created_at > stamp ? :create : :update)}
  end

  def self.add_tags(params, user, ctx)
    entry = Entry.comment_counts.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    Array(params['tags']).each do |tag|
      entry.tags.push(tag) unless entry.tags.find_all {|t| t.downcase == tag.downcase}.length > 0
    end
    entry.save
    entry.broadcast(:update, params[:sid])
    entry
  end

  def self.remove_tags(params, user, ctx)
    entry = Entry.comment_counts.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    Array(params['tags']).each do |tag|
      tag = tag.downcase
      entry.tags.delete_if {|t| t.downcase == tag}
    end
    entry.save
    entry.broadcast(:update, params[:sid])
    entry
  end
  def self.edit_class(params, user, ctx)
    entry = Entry.comment_counts.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)

    entry.classes ||= []
    entry.classes.push(params['class_name']) unless entry.classes.include?(params['class_name'])
    entry.metadata[params['class_name']] = params['cfg']
    entry.save
    entry.broadcast(:update, params[:sid])
    entry
  end
  def self.destroy(params, user, ctx)
    entry = Entry.comment_counts.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    entry.destroy
    entry.broadcast(:destroy, params[:sid])
    entry
  end
  def self.search(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    if params[:group_id]
      group = UserGroup.where(id: params[:group_id]).first
      raise BrisaApiError.new('Group not found') unless group
      raise BrisaApiError.new('Access denied') unless group.view?(user)
    end
    result = Entry.all.comment_counts
    if params['tags']
      if params['tags'].length == 0
        result = result.where('cardinality(tags) = 0')
      else
        result = result.where('tags @> ARRAY[?]::varchar[]', Array(params['tags']))
      end
    end
    if params['classes']
      result = result.where('classes @> ARRAY[?]::varchar[]', Array(params['classes']))
    end
    if params[:group_id]
      result = result.where(group_id: params[:group_id]).order(created_at: :desc)
    else
      result = result.where(owner_uid: user.uid, group_id: nil).order(created_at: :desc)
    end
    result
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    data = params.require(:data)
    owner = user.uid
    group_id = data[:group_id]
    if group_id
      group = UserGroup.where(id: data[:group_id]).first
      raise BrisaApiError.new('Group not found') unless group
      raise BrisaApiError.new('Access denied') unless group.edit?(user)
      owner = group.owner_uid
    end
    data[:metadata] ||= {}
    opts = { owner_uid: owner, creator_uid: user.uid, group_id: group ? group.id : nil,
      title: data[:title], description: data[:description],
      tags: Array(data[:tags]), classes: Array(data[:classes]),
      metadata: data[:metadata]}
    entry = Entry.create!(opts)
    is_read = !data[:is_role]
    BrisaNotifier.EntryCreated(entry.user_group, user, is_read, entry, data[:ctx])
    entry.broadcast(:create, params[:sid])
    entry
  end

  def self.partial(params, user, ctx)
    entry = Entry.comment_counts.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)

    # Rails handling of safe params is convoluted, and can't whitelist
    # an entire structure for jsonb fields.
    actions = params.to_unsafe_h[:actions]
    entry.with_lock do
      actions.each do |act|
        failed = entry.apply(act)
        raise BrisaApiError.new(failed[:msg], :error, {a: act}) if failed
      end
      entry.save
    end
    entry.broadcast(:update, params[:sid])
    entry
  end

  def self.update(params, user, ctx)
    entry = Entry.comment_counts.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.edit?(user)
    data = params.require(:data)
    entry.with_lock do
      entry.update(title: data[:title], description: data[:description],
        tags: data[:tags], classes: data[:classes],
        metadata: data[:metadata], due_at: data[:due_at], archived: data[:archived],
        time_est: data[:time_est], completed_at: data[:completed_at])
    end
    entry.broadcast(:update, params[:sid])
    entry
  end
end
