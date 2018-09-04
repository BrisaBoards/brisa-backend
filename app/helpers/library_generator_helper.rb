module LibraryGeneratorHelper
  def ObjActions(obj)
    @ns.objects[obj].actions.keys
  end

  def ActionOpts(obj, action)
    @ns.objects[obj].actions[action][:opts]
  end

  def InstanceMethods(obj)
    inst_methods = {}
    @ns.objects[obj].actions.each do |k,v|
      inst_methods[k] = v[:opts] if v[:opts][:instance]
    end
    inst_methods
  end

  def InstanceArgs(opts)
    rem_args = Array(opts[:instance]) + Array(opts[:include_data])
    arg_list = opts[:args] - rem_args.map(&:to_s)
    puts "InstArgs: (#{arg_list.join(",")})" + opts.inspect + " -- #{rem_args}"
    return arg_list
  end

  def ActionReturnType(opts, lang_null='null', cls_prefix='Brisa')
    if opts[:returns].is_a? Array
      return cls_prefix + opts[:returns][0]
    elsif opts[:returns] == :data or opts[:returns].nil?
      return lang_null
    elsif opts[:returns] == :self
      return lang_null
    else
      return cls_prefix + opts[:returns]
    end
  end
end
