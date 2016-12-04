class Ecman::Driver
  include Ecman::Logger::Helper
  include Ecman::Utils::Diff

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def create(name, attrs)
    log(:info, "Create '#{name}'", color: :cyan)

    unless @options[:dry_run]
      attrs.update('cron_job_name' => name)
      @client.add(**symbolize(attrs))
    end
  end

  def delete(name, attrs)
    cron_job_id = attrs.delete('cron_job_id')
    log(:info, "Delete '#{name}'", color: :red)

    unless @options[:dry_run]
      @client.delete(id: cron_job_id)
    end
  end

  def update(name, attrs, old_attrs)
    cron_job_id = old_attrs.delete('cron_job_id')
    log(:info, "Update '#{name}'", color: :green)
    log(:info, diff(old_attrs, attrs, color: @options[:color]), color: false)

    unless @options[:dry_run]
      attrs.update('id' => cron_job_id, 'cron_job_name' => name)
      @client.edit(**symbolize(attrs))
    end
  end

  private

  def symbolize(attrs)
    attrs.map {|k, v| [k.to_sym, v] }.to_h
  end
end
