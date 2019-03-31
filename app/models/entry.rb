class Entry < ApplicationRecord
  belongs_to :user_group, foreign_key: :group_id, optional: true
  has_many :comments

  SET_ATTRS = [:title, :description, :tags, :classes, :metadata, :due_at,
      :start_at, :archived, :time_est, :completed_at]
  ARR_ATTRS = [:tags, :classes]
  
  def self.comment_counts
    joins('left join comments on comments.entry_id = entries.id').
    select('entries.*, count(comments.id) as comment_count').
    group('entries.id')
  end

  def parse_metadata_path(path_string)
    full_path = path_string.split('.')
    path = full_path[1..-2]
    cur_path = self.metadata

    # Traverse path, except last element
    path.each do |attr|
      if cur_path.is_a? Hash
        cur_path = cur_path[attr]
      elsif cur_path.is_a? Array
        cur_path = cur_path[attr.to_i]
      else
        return nil
      end
    end

    # Check that last element of path exists.
    has_key = true
    if cur_path.is_a?(Hash)
      has_key = false unless cur_path.has_key?(full_path[-1])
    elsif cur_path.is_a?(Array)
      has_key = false unless cur_path.length > full_path[-1].to_i
    else
      return nil
    end

    return {path: cur_path, has_key: has_key, key: cur_path.is_a?(Hash) ? full_path[-1] : full_path[-1].to_i}
  end

  def apply(action)
    act = action[0]

    # set my_attr|metadata.cls.etc new_val
    if act == 'set'
      act, attr, val, dont_fail = action
      if SET_ATTRS.include?(attr.to_sym)
        self[attr] = val
      elsif attr.starts_with? 'metadata.'
        change = parse_metadata_path(attr)
        if change.nil?
          return {msg: "Path not found: #{attr} - #{self.metadata.inspect}"} unless dont_fail
        else
          change[:path][change[:key]] = val
        end
      else
        return {msg: "Attribute not found: #{attr}"} unless dont_fail
      end

    # arr_add my_attr|metadata.arr_field new_val
    elsif act == 'arr_add'
      act, attr, val, dont_fail  = action
      if ARR_ATTRS.include?(attr.to_sym)
        self[change[:key]].push val
      elsif attr.starts_with? 'metadata.'
        change = parse_metadata_path(attr)
        if change.nil?
          return {msg: "Path not found: #{attr}"} unless dont_fail
        else
          change[:path][change[:key]].push val
        end
      elsif !dont_fail
        return {msg: "Can't append to: #{attr}"}
      end
    end

    return false
  end

  def edit?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.edit?(user)
    return false
  end
  def view?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.view?(user)
    return false
  end
  def comment?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.comment?(user)
    return false
  end
  def admin?(user)
    return true if user.uid == self.owner_uid
    return true if self.user_group and self.user_group.admin?(user)
    return false
  end

  def user_uids
    if self.group_id.nil?
      return [self.owner_uid]
    end

    return ([self.owner_uid] + self.user_group.access.keys).uniq
  end

  def ws_message(action, session_id=nil)
    msg = {
      m: 'ent',
      a: action,
      gid: self.group_id,
      id: self.id,
      tags: self.tags,
      classes: self.classes
    }
    msg[:sid] = session_id if session_id
    return msg
  end

  def broadcast(action, session_id=nil)
    msg = self.ws_message(action, session_id)
    user_uids.each do |uid|
      ActionCable.server.broadcast("user_#{uid}", msg)
    end
  end
end
