class SearchIndexFullService < SearchIndexServiceBase


  private

  def execute
    if @options[:clean]
      wipe_index
    end
    Resource.pluck(:id).each do |id|
      SearchIndexResourceTreeJob.perform_later(id)
    end
  end
end
