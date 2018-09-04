# A simple, action-based API and dispatcher that can self-document.

class BrisaApiError < StandardError
  def initialize(message, error_data={})
    error_data[:error] = message
    @error_data = error_data
  end

  def error_data
    return @error_data
  end
end

class BrisaApiDispatcher
  @@singleton = nil
  attr_accessor :ns

  def self.singleton
    @@singleton ||= BrisaApiDispatcher.new()
    return @@singleton
  end

  def initialize
    @ns = {}
  end

  def api(api)
    @ns[api.namespace] = api
  end

  def do_call(params, user, ctx, namespace=nil)
    raise BrisaApiError.new('Namespace not found') unless namespace = @ns[namespace]
    api_obj, api_action = (params[:act] || '').split(":")
    raise BrisaApiError.new("Unknown action #{params[:act]}") unless api_obj = namespace.objects[api_obj]
    raise BrisaApiError.new("Unknown action #{params[:act]}") unless api_action = api_obj.actions[api_action]

    return api_action[:block].call(params, user, ctx)
  end
end

class BrisaAPI
  attr_accessor :objects, :namespace
  @@singletons = {}

  def initialize(namespace)
    @namespace = namespace
    @objects = {}
  end

  def self.singleton(namespace)
    @@singletons[namespace] ||= BrisaAPI.new(namespace)
    return @@singletons[namespace]
  end

  def Object(name, opts={})
    @objects[name] = BrisaApiObj.new(name, opts)
  end
end

class BrisaApiObj
  attr_accessor :actions, :opts
  def initialize(name, opts=nil)
    @name = name
    @opts = opts
    @actions = {}
  end

  def Action(name, opts={}, &block)
    @actions[name] = { opts: opts, block: block }
  end
end
