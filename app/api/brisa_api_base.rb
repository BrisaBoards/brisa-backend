class BrisaAPIBase
  def self.api_namespace(ns)
    @@_api_base = BrisaAPI.singleton(ns)
    BrisaApiDispatcher.singleton.api(@@_api_base)
  end

  def self.api_object(name, opts={})
    @@_api_obj = @@_api_base.Object(name, opts)
  end

  def self.api_action(name, opts={})
    @@_api_obj.Action(name, opts) do |params, user, ctx|
      send(name.to_sym, params, user, ctx)
    end
  end
end
