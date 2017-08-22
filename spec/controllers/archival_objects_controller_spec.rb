require 'spec_helper'

DatabaseCleaner.start

describe ArchivalObjectsController, :type => :controller do
  
  it "returns batches of html for multiple objects" do
    archival_objects = create_list(:archival_object,10)
    get :batch_html, :ids => archival_objects.map { |x| x.id }
    puts response.body
    expect(response.body).to be_a_kind_of(String)
  end

end

DatabaseCleaner.clean
