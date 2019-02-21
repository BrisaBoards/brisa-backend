# Container to hold notification info for easy creation.
class BrisaNotificationMessage
  attr_accessor :group_id,
    :actor_id,
    :notify_type, # entry_create, entry_update, entry_comment, system
    :title, :description,
    :link_url, :link_title,
    :client_link, :client_link_id # entry / 1
end

# Class to check and deliver notifications to users.
class BrisaNotifier

  # Deliver a notification to a user and send websocket message.
  # Args:
  #   user: User to send notification to.
  #   message: {by: uid, msg: 'A message'[, link_title: 'My Title', link_url: 'https://...']}
  #   parent: Object that was change. Eg 'entry:5'
  #   ctx: The context the change was made in. Eg '5-_kanban'
  #   collapse: If true, attempt to collapse into similar notifications.
  def self.Notify(user, message, parent, ctx, collapse)
    # save notification or append
    # send ws message
    notify = collapse ? Notification.where(user_id: user.id, parent: parent).first : nil
    notify = Notification.new(user_id: user.id, parent: parent, ctx: ctx, messages: []) unless notify
    notify.messages.push message
    is_new = notify.id.nil?
    notify.save!
    notify.broadcast(is_new ? 'new' : 'up')
  end

  def self.EntryCreated(group, user, is_read, entry, ctx)
    self.FindMatches(group, user, is_read) do |u, notify|
      if notify.include?('all') or notify.include?('new')
        msg = {by: user.uid, msg: 'Created.'}
        parent = "entry:#{entry.id}"
        self.Notify(u, msg, parent, ctx, true)
      end
    end
  end

  def self.EntryAssigned(entry, user, assignee, is_assigned, is_read, ctx)
    assign_str = is_assigned ? 'Assigned' : 'Unassigned'
    parent = "entry:#{entry.id}"
    msg = {by: user.uid, msg: assign_str, assignee: assignee}
    self.FindMatches(entry.user_group, user, is_read) do |u, notify|
      if notify.include?('assigned') and assignee == u.uid
        self.Notify(u, msg, parent, ctx, true)
      elsif notify.include?('mine') and entry.owner_uid == u.uid
        self.Notify(u, msg, parent, ctx, true)
      elsif entry.watchers.include?(u.uid)
        self.Notify(u, msg, parent, ctx, true)
      elsif notify.include?('all')
        self.Notify(u, msg, parent, ctx, true)
      end
    end
  end

  def self.EntryComment(group, user, is_read, entry, comment, ctx)
    msg = {by: user.uid, msg: "New comment: #{comment.comment[0..29]}"}
    parent = "entry:#{entry.id}"
    self.FindMatches(group, user, is_read) do |u, notify|
      if notify.include?('assigned') and entry.assignees.include?(u.uid)
        self.Notify(u, msg, parent, ctx, true)
      elsif entry.watchers.include?(u.uid)
        self.Notify(u, msg, parent, ctx, true)
      elsif notify.include?('mine') and entry.creator_uid == u.uid
        self.Notify(u, msg, parent, ctx, true)
      elsif notify.include?('all')
        self.Notify(u, msg, parent, ctx, true)
      end
    end
  end

  def self.EntryUpdate(group, user, is_read, entry, field, desc)
  end

  def self.System(title, message, ex={}, collapse=false)
    parent = "system"
    msg = {title: title, msg: message}.merge(ex)
    User.all.each do |u|
      self.Notify(u, msg, parent, nil, collapse)
    end
  end

  # Helper to loop through group users and get notification settings.
  # It will skip a user if it matches the user making the change, unless
  # is_read is false.
  def self.FindMatches(group, user, is_read, &block)
    # If group is nil, it's the user's person group.
    if group.nil?
      block.call(user, ['all']) unless is_read
      return
    end

    User.where(uid: [group.owner_uid] + group.access.keys).each do |u|
      # notify = group.notify[user.uid]
      notify = nil
      if notify.nil?
        notify = group == nil ? ['all'] : ['mine', 'assigned']
      end
      next if (user.id == u.id and is_read)
      block.call(u, notify)
    end
  end

  def self.watching?(entry, user)
    # return true if entry.watchers.include?(user.uid)
  end

end
