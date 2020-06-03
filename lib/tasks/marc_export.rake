namespace :marc_export do
  desc "execute MARC XML export for resources updated in the last n days"
  task :execute, [:days] => :environment do |t, args|
    days = args[:days] || 7
    options = { days: days }
    response = ExportMarcXml.call(options)
    puts response.inspect
    if response[:report_path]
      path = response[:report_path]
      to = ENV['marc_export_email_recipient']
      from = ENV['marc_export_email_sender']
      subject = "ArchivesSpace resources updated in the past #{days} days"
      `mail -a #{path} -s '#{subject}' -r #{from} #{to} < /dev/null`
    end
  end
end
