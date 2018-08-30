
class BrisaController < ApplicationController
  # TODO: Refactor API so functions are included directly in controller
  # and has access to all controller data.
  BrisaEntry; BrisaUser; BrisaModel; BrisaUserSetting;

  skip_before_action :verify_authenticity_token

  def get_binding; binding; end

  def api_request
    # TODO: If API token is provided, use that. Otherwise, verify auth token and set user.

    begin
      render json: {data: BrisaApiDispatcher.singleton.do_call(params, current_user, self, params[:namespace])}
    rescue BrisaApiError => e
      # TODO: Refactor exceptions to include an error code (:not_found, :access_denied, etc)
      render status: :error, json: e.error_data
    rescue StandardError => e
      render status: :error, json: {error: Rails.env == 'development' ? "Internal error: #{e.message}" : 'Internal error'}
      raise e
    end
  end

private

  def current_user
    if session[:user_id]
      return User.where(id: session[:user_id]).first
    end

    return nil
  end
end
