class AspaceImportFullJob < ApplicationJob
  queue_as :import

  def perform(*args)
    options = args[0]
    ExecuteAspaceFullImport.call(options)
    AspaceImport.purge_deleted
    SearchIndexFullService.call
  end
end
