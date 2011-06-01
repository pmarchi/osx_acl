
require 'ostruct'
require 'optparse'

class OsxAcl::Script
  MYVERSION = "0.1.2"

  def parse(args)
    # The options specified on the command line will be collected in *options*.
    options = OpenStruct.new
    # Default values go here:
    options.aces = nil
    options.clear = false
    options.recursive = false

    opts = OptionParser.new do |opt|
      opt.banner = "Set Mac OS X style ACL Entries on a Directory.\n\nUsage: #{File.basename $0} [options] <dir>"
      opt.separator ""
      opt.separator "Specific options:"

      opt.on("-c", "--clear", "Clear acl on dir.") do
        options.clear = true
      end

      opt.on("-C", "--clear-recursive", "Clear acl on dir, sub-dir and files.") do
        options.clear = :recursive
      end

      opt.on("-a", "--ace ACE,...", Array, "Set aces on dir.", "ACE has the form: user|group:name:ro|rw") do |aces|
        options.aces = aces.map do |ace|
          type, name, perm = ace.split(':')
          ["#{type}:#{name}", perm.to_sym]
        end
      end

      opt.on("-r", "--recursive", "Recursively set permission on path.") do
        options.recursive = true
      end

      opt.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opt.on_tail("--version", "Show version") do
        puts MYVERSION
        exit
      end
    end

    begin    
      opts.parse!(args)
    rescue => exc
      STDERR.puts "Error: #{exc.message}"
      STDERR.puts opts.to_s
      exit 1
    end

    # TODO
    # if inheritance is set rewrite short permissions :ro => :roi, :rw => :rwi
    options
  end
end