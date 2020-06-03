class AspaceImportWeeklyJob < ApplicationJob
  queue_as :import

  def perform(*args)
    # go back 25 hours just in case!
    options = {
      since: 180.hours.ago,
      import_type: 'weekly'
    }
    ExecuteAspaceDeltaImport.call(options)
    AspaceImport.purge_deleted
    SearchIndexPartialJob.perform_later('weekly')
  end
end
