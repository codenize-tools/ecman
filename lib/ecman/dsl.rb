class Ecman::DSL
  ROOT_KEY = 'cron_job'

  class << self
    def convert(exported)
      Dslh.deval(exported, root_identify: true)
    end

    def parse(dsl, path, options = {})
      Ecman::DSL::Context.eval(dsl, path, options)
    end
  end # of class methods
end
