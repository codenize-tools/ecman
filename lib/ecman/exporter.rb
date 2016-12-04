class Ecman::Exporter
  include Ecman::Utils::TargetMatcher

  def initialize(client, options = {})
    @client = client
    @options = options
  end

  def export(without_cron_job_id: false)
    result = {}
    cron_jobs = result[Ecman::DSL::ROOT_KEY] = {}

    @client.list.fetch('cron_jobs').each do |cron_job|
      cron_job_name = cron_job.fetch('cron_job_name')
      next if cron_job_name.empty?

      cron_jobs[cron_job_name] = {
        'cron_expression' => cron_job.fetch('cron_expression'),
        'url' => cron_job.fetch('url'),
        'email_me' => cron_job.fetch('email_me').to_i,
        'log_output_length' => cron_job.fetch('log_output_length').to_i,
      }

      unless without_cron_job_id
        cron_jobs[cron_job_name]['cron_job_id'] = cron_job.fetch('cron_job_id').to_i
      end

      %w(cookies posts via_tor).each do |key|
        value = cron_job[key]
        cron_jobs[cron_job_name][key] = value if value
      end
    end

    result
  end
end
