class AspaceImportDailyJob < ApplicationJob
  queue_as :import

  def perform(*args)
    # go back 25 hours just in case!
    options = {
      since: 25.hours.ago,
      import_type: 'daily'
    }
    ExecuteAspaceDeltaImport.call(options)
    AspaceImport.purge_deleted
    SearchIndexPartialJob.perform_later('daily')
  end
end
