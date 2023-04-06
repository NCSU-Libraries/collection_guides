class SearchIndexFullJob < ApplicationJob
  queue_as :index

  def perform(*args)
    options = args[0] || {}
    s = SearchIndex.new
    s.execute_full(options)
  end
end
