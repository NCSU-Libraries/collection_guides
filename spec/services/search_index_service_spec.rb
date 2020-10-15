require 'spec_helper'

RSpec.describe do


  describe "SearchIndexResourceTreeService" do

    it "indexes records at all levels of hierarchy" do
      resource = create(:resource)
      archival_objects = create_list(:archival_object, 51, :resource_id => resource.id)
      resource.reload
      service_response = SearchIndexResourceTreeService.call(resource_id: resource.id)
      expect(service_response[:error]).to be_nil
      expect(service_response[:records_indexed][:resources]).to eq(1)
      expect(service_response[:records_indexed][:archival_objects]).to eq(51)
    end

  end

end
