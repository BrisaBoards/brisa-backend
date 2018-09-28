class BrisaEntry < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Entry', attrs: %w(title description metadata tags classes created_at updated_at)

  api_action 'search', args: %w(tags classes), returns: ['Entry']
  api_action 'create', args: %w(data), returns: 'Entry'
  api_action 'update', args: %w(id data), instance: :id, include_data: :data, returns: :self
  api_action 'add_tags', args: %w(id tags), instance: :id, returns: :self
  api_action 'remove_tags', args: %w(id tags), instance: :id, returns: :self
  api_action 'edit_class', args: %w(id class_name cfg), instance: :id, returns: :self
  api_action 'destroy', args: %w(id), instance: :id

  def self.add_tags(params, user, ctx)
    entry = Entry.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.owner_id == user.id
    Array(params['tags']).each do |tag|
      entry.tags.push(tag) unless entry.tags.find_all {|t| t.downcase == tag.downcase}.length > 0
    end
    entry.save
    entry
  end

  def self.remove_tags(params, user, ctx)
    entry = Entry.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.owner_id == user.id
    Array(params['tags']).each do |tag|
      tag = tag.downcase
      entry.tags.delete_if {|t| t.downcase == tag}
    end
    entry.save
    entry
  end
  def self.edit_class(params, user, ctx)
    entry = Entry.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.owner_id == user.id
    
    entry.classes ||= []
    entry.classes.push(params['class_name']) unless entry.classes.include?(params['class_name'])
    entry.metadata[params['class_name']] = params['cfg']
    entry.save
    entry
  end
  def self.destroy(params, user, ctx)
    entry = Entry.find(params['id'])
    raise BrisaApiError.new('Access denied') unless entry.owner_id == user.id
    entry.destroy
    entry
  end
  def self.search(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    result = Entry.all
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
    result = result.where(owner_id: user.id).order(created_at: :desc)
  end

  def self.create(params, user, ctx)
    raise BrisaApiError.new('Access denied') unless user
    data = params.require(:data)
    data[:metadata] ||= {}
    opts = { owner_id: user.id, creator_id: user.id,
      title: data[:title], description: data[:description],
      tags: Array(data[:tags]), classes: Array(data[:classes]),
      metadata: data[:metadata]}
    Entry.create(opts)
  end

  def self.update(params, user, ctx)
    entry = Entry.find(params[:id])
    raise BrisaApiError.new('Access denied') unless entry.owner_id == user.id
    data = params.require(:data)
    entry.update(title: data[:title], description: data[:description],
      tags: data[:tags], classes: data[:classes],
      metadata: data[:metadata])
    entry
  end
end
