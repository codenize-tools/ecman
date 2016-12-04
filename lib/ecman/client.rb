class Ecman::Client
  include Ecman::Utils::TargetMatcher

  def initialize(options = {})
    @options = options
    @client = @options[:client] || Easycron::Client.new(token: options.fetch(:token))
    @driver = Ecman::Driver.new(@client, options)
    @exporter = Ecman::Exporter.new(@client, @options)
  end

  def export
    expected = @exporter.export(without_cron_job_id: true)
    Ecman::DSL.convert(expected)
  end

  def apply(file)
    expected = load_file(file)
    actual =  @exporter.export

    updated = walk(expected, actual)

    if @options[:dry_run]
      false
    else
      updated
    end
  end

  private

  def walk(expected, actual)
    expected = expected.fetch(Ecman::DSL::ROOT_KEY)
    actual = actual.fetch(Ecman::DSL::ROOT_KEY)

    updated = false

    expected.each do |name, expected_attrs|
      next unless target?(name)

      actual_attrs = actual.delete(name)

      if actual_attrs
        actual_attrs_without_id = actual_attrs.dup
        actual_attrs_without_id.delete('cron_job_id')

        if expected_attrs != actual_attrs_without_id
          @driver.update(name, expected_attrs, actual_attrs)
          updated = true
        end
      else
        @driver.create(name, expected_attrs)
        updated = true
      end
    end

    actual.each do |name, actual_attrs|
      next unless target?(name)
      @driver.delete(name, actual_attrs)
      updated = true
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Ecman::DSL.parse(f.read, file, @options)
      end
    elsif file.respond_to?(:read)
      Ecman::DSL.parse(file.read, file.path, @options)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
