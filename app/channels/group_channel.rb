class GroupChannel < ApplicationCable::Channel
  def subscribed
    user = BrisaJWT.check_token(connection.auth_token)
    if !user
      reject
      return
    end
    if params[:group] == ''
      stream_from "group_user_#{user.id}"
    else
      group = UserGroup.where(id: params[:group]).first
      if !group
        reject
      elsif group.view?(user)
        stream_from "group_#{group.id}"
      else
        reject
      end
    end
  end
end
