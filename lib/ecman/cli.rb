class Ecman::CLI < Thor
  include Ecman::Logger::Helper

  MAGIC_COMMENT = <<-EOS
  # -*- mode: ruby -*-
  # vi: set ft=ruby :
  EOS


  class_option :target
  class_option :color, type: :boolean, default: true
  class_option :debug, type: :boolean, default: false

  desc 'apply FILE', 'apply'
  option :'dry-run', type: :boolean, default: false
  def apply(file)
    cli = client(options)

    log(:info, "Apply `#{file}`")
    updated = client(options).apply(file)

    unless updated
      log(:info, 'No change'.intense_blue)
    end
  end

  desc 'export [FILE]', 'export'
  def export(file = nil)
    cli = client(options)
    dsl = cli.export

    if file.nil? or file == '-'
      puts dsl
    else
      log(:info, "Export to `#{file}`")
      open(file, 'wb') {|f| f.puts dsl }
    end
  end

  desc 'version', 'show version'
  def version
    puts Ecman::VERSION
  end

  private

  def client(options)
    options = options.dup
    underscoreize!(options)

    String.colorize = options[:color]
    Ecman::Logger.instance.set_debug(options[:debug])


    cli = Ecman::Client.new(options)
  end

  def underscoreize!(options)
    options.keys.each do |key|
      if key.to_s =~ /-/
        if value = options.delete(key)
          key = key.to_s.gsub('-', '_').to_sym
          options[key] = value
        end
      end
    end
  end
end
