class Ecman::DSL::Context
  include Ecman::Logger::Helper

  SCHEMA_YML = File.expand_path('../schema.yml', __FILE__)

  def self.eval(dsl, path, options = {})
    self.new(path, options).eval(dsl)
  end

  def initialize(path, options = {})
    @path = path
    @options = options
    @result = {}
    @templates = {}

    @context = Hashie::Mash.new(
      path: path,
      options: options,
    )
  end

  def eval(dsl)
    scope_hook = proc do |scope|
      scope.instance_eval(<<-'EOS')
        def template(name, &block)
          @templates[name.to_s] = block
        end

        def include_template(template_name, context = {})
          tmpl = @templates[template_name.to_s]

          unless tmpl
            raise "Template '#{template_name}' is not defined"
          end

          context_orig = @context
          @context = @context.merge(context)
          instance_eval(&tmpl)
          @context = context_orig
        end

        def context
          @context
        end
      EOS
    end

    scope_vars = {templates: @templates, context: @context}

    begin
      Dslh.eval(dsl, {
        filename: @path,
        allow_empty_args: true,
        scope_hook: scope_hook,
        scope_vars: scope_vars,
        root_identify: true,
        schema_path: SCHEMA_YML,
      })
    rescue Dslh::ValidationError => e
      if @options[:debug]
        log(:debug, "Parsed DSL: \n" + e.data.pretty_inspect)
      end

      raise e
    end
  end

  private

  def template(name, &block)
    @templates[name.to_s] = block
  end
end
