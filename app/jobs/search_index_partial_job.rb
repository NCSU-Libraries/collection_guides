class SearchIndexPartialJob < ApplicationJob
  queue_as :index

  def perform(*args)
    mode = args[0]
    s = SearchIndex.new
    case mode
    when 'hourly'
      s.execute_hourly
    when 'daily'
      s.execute_daily
    when 'weekly'
      s.execute_weekly
    else
      s.execute_delta
    end
  end
end
