# generic permission
#   delete readattr writeattr readextattr writeextattr readsecurity writesecurity chown
# dirextory permissions
#   list search add_file add_subdirectory delete_child  
# file permissions
#   read write append execute
# inheritance
#   file_inherit directory_inherit limit_inherit only_inherit

class OsxAcl::Dir
  # drwxr-xr-x+ 3 pmarchi  staff  102 May 31 09:22 /Users/pmarchi/tmp/acls/exist/bar/
  #    0: user:pmarchi inherited allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit
  #    1: group:staff inherited allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit

  # Regexp for parsing acl
  ACL_RX = /^\s+(\d+):\s+(\w+:\w+)\s+(?:(inherited)\s+)?(allow|deny)\s+(.*)$/

  # Predefined set of permissions
  #   ro => read only
  #   rw => read/write
  PSET = {
    'ro'  => 'readattr,readextattr,readsecurity,list,search,read,execute',
    'rw'  => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,list,search,read,write,append,execute,add_file,add_subdirectory,delete_child',
    'fdi' => 'file_inherit,directory_inherit',
  }

  attr_reader :dir
  attr_reader :debug
  
  def initialize(dir, options={})
    @dir = dir
    @debug = options[:debug]
  end
  
  def get
    acl = run 'ls -dle', "'#{dir}'"
    # @acl = parse(run 'ls -dle', dir)
    acl
  end

  def parse(list)
    list.scan(ACL_RX)
  end

  # Clear acl on dir
  #
  def clear(options)
    r = options[:recursive] ? '-R' : ''
    run 'chmod', r, '-N', "'#{dir}'"
  end
  
  # Set aces on dir
  # e.g.
  #   #set([['user:patrick', :rw, :ri], ['user:katja', :ro, :i]])
  #
  def set(aces)
    aces.reverse.each do |actor, pset, flags|
      inherit, recursive = parse_flags(flags)
      run "chmod +a '#{actor} allow #{build_pset(pset, inherit)}' '#{dir}'"
      run "find '#{dir}' -mindepth 1 -exec chmod +ai '#{actor} allow #{build_pset(pset, inherit)}' {} \\;" if recursive
    end
  end
  
  def parse_flags(flags)
    flags = String(flags)
    return ['fdi', true] if flags.include?('r')
    return ['fdi', false] if flags.include?('i')
    [false, false]
  end
  
  def build_pset(pset, inherit)
    [PSET[pset], PSET[inherit]].compact.join(',')
  end
  
  def run(*args)
    puts '--> ' + args.join(' ') if debug
    `#{args.join(' ')}`
  end
end
