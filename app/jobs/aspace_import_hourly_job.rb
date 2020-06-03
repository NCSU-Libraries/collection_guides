class AspaceImportHourlyJob < ApplicationJob
  queue_as :import

  def perform(*args)
    hours = args[0] || 1
    options = {
      since: hours.to_i.hours.ago,
      import_type: 'hourly'
    }
    ExecuteAspaceDeltaImport.call(options)
    AspaceImport.purge_deleted
    SearchIndexPartialJob.perform_later('hourly')
  end
end
