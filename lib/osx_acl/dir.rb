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
    :ro => 'readattr,readextattr,readsecurity,list,search,read,execute',
    :rw => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,list,search,read,write,append,execute,add_file,add_subdirectory,delete_child',
    :roi => 'readattr,readextattr,readsecurity,list,search,read,execute,file_inherit,directory_inherit',
    :rwi => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,list,search,read,write,append,execute,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit',
  }

  attr_reader :dir
  attr_reader :acl
  
  def initialize(dir)
    @dir = dir
  end
  
  def get
    acl = run 'ls -dle', dir
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
    run 'chmod', r, '-N', dir
  end
  
  # Set aces on dir
  # e.g.
  #   #set([['user:patrick', :rw], ['user:katja', :ro]], :recursive => true)
  #
  def set(aces, options)
    # TODO
    # every ace should have a flag for recursive and one flag for inheritance permission
    aces.reverse.each do |actor, short_permissions|
      run "chmod +a '#{actor} allow #{PSET[short_permissions]}' #{dir}"
      run "find #{dir} -mindepth 1 -exec chmod +ai '#{actor} allow #{PSET[short_permissions]}' {} \\;" if options[:recursive]
    end
  end
  
  def run(*args)
    puts '--> ' + args.join(' ')
    `#{args.join(' ')}`
  end
end
