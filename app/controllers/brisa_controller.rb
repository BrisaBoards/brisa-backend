require './lib/brisa_jwt'

class BrisaController < ApplicationController
  # TODO: Refactor API so functions are included directly in controller
  # and has access to all controller data.
  BrisaEntry; BrisaUser; BrisaModel; BrisaUserSetting; BrisaGroup; BrisaRole; BrisaComment; BrisaNotification

  skip_before_action :verify_authenticity_token

  def api_request
    # TODO: If API token is provided, use that. Otherwise, verify auth token and set user.

    begin
      render json: {data: BrisaApiDispatcher.singleton.do_call(params, current_user, self, params[:namespace])}
    rescue BrisaApiError => e
      # TODO: Refactor exceptions to include an error code (:not_found, :access_denied, etc)
      render status: :bad_request, json: e.error_data
    rescue StandardError => e
      render status: :internal_server_error, json: {error: Rails.env == 'development' ? "Internal error: #{e.message}" : 'Internal error'}
      raise e
    end
  end

private

  def current_user
    if params[:auth_token]
      return BrisaJWT.check_token(params[:auth_token])
      begin
        token_data = JWT.decode(params[:auth_token], Rails.application.credentials.secret_key_base)[0]
        if token_data['user_id']
          return User.where(id: token_data['user_id']).first
        elsif token_data['rol']
          role = Role.where(id: token_data['rol']).first
          return User.where(id: role.user_id).first if role
        end
      rescue StandardError => e
        logger.info(e)
      end
      return nil
    end

    return nil
  end
end
