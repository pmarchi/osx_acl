
require 'ostruct'
require 'optparse'

class OsxAcl::Script
  MYVERSION = "0.1.2"

  def parse(args)
    # The options specified on the command line will be collected in *options*.
    options = OpenStruct.new
    # Default values go here:
    options.permissions = nil
    options.recursiv = false

    opts = OptionParser.new do |opt|
      opt.banner = "Set Mac OS X style ACL Entries on Path.\n\nUsage: #{File.basename $0} [options] <path>"
      opt.separator ""
      opt.separator "Specific options:"

      opt.on("-p", "--permissions [PERM]", String, "Set permissions.", "PERM is one of ro,rw,fc.") do |permission|
        options.permission = permission
      end

      opt.on("-r", "--recursive", "Recursively set permission on path.") do
        options.recursiv = true
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

    options
  end
end