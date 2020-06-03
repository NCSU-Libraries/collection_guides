class AspaceImportFullJob < ApplicationJob
  queue_as :import

  def perform(*args)
    options = args[0]
    ExecuteAspaceFullImport.call(options)
    AspaceImport.purge_deleted
    SearchIndexFullJob.perform_later
  end
end
