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

  # Predefined set of permissions for directories
  #   ro => read only
  #   rw => read/write
  PSET = {
    :ro => 'readattr,readextattr,readsecurity,list,search,file_inherit,directory_inherit',
    :rw => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,list,search,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit',
  }

  PSET_DIR = {
    :ro => 'readattr,readextattr,readsecurity,list,search,file_inherit,directory_inherit',
    :rw => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,list,search,add_file,add_subdirectory,delete_child,file_inherit,directory_inherit',
  }

  # Predefined set of permissions for files
  PSET_FILE = {
    :ro => 'readattr,readextattr,readsecurity,read,execute',
    :rw => 'delete,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,read,write,append,execute',
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

  # Set aces on dir
  # e.g.
  #   #set([['user:patrick', :rw], ['user:katja', :ro]], :recursive => true)
  def set(aces, options)
    run commands(dir, aces).join(' && ')
    run commands_r(dir, aces).join(' && ') if options[:recursive]
  end
  
  def parse(list)
    list.scan(ACL_RX)
  end

  # TODO
  # Simplify code and remove distinction of dir and file, because all settings
  # could be applied to files and dirs as well. Only the permissions will be set
  # which make sens for the given type.

  
  # Consturct a sequence of chmod commands which will first clear the ACL and
  # then insert an ace for every actor specified by aces. The commands will be
  # returned as an array.
  #
  # => ['chmod -N path',
  #     'chmod +a# 0 actor allow permission path',
  #     'chmod +a# 1 actor allow permission path']
  #
  def commands(path, aces, pset=PSET_DIR, inherited=false)
    cmds = ["chmod -N #{path}"]
    sub_cmd = inherited ? '+ai#' : '+a#'
    aces.each_with_index do |(actor, short_permissions), index|
      cmds << "chmod #{sub_cmd} #{index} '#{actor} allow #{pset[short_permissions]}' #{path}"
    end
    cmds
  end
  
  # Wraps the commands from above in order to feed them to find.
  #
  # => ['find path -mindepth 1 -type d -exec cmd_dir1 \; -exec cmd_dir2 \;',
  #     'find path -mindepth 1 -type f -exec cmd_file1 \; -exec cmd_file2 \;']
  #
  def commands_r(path, aces)
    cmds = []
    cmds << "find #{path} -mindepth 1 -type d #{commands('{}', aces, PSET_DIR, true).map {|cmd| "-exec #{cmd} \\;"}.join(' ')}"
    cmds << "find #{path} -mindepth 1 -type f #{commands('{}', aces, PSET_FILE, true).map {|cmd| "-exec #{cmd} \\;"}.join(' ')}"
    cmds
  end
  
  def run(*args)
    `#{args.join(' ')}`
  end
end
