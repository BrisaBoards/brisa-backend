class BrisaApiTmpl < BrisaAPIBase
  api_namespace 'Brisa0'
  api_object 'Tmpl'

  api_action 'status', args: %w()

  def self.status(params, user, ctx)
  end
end
