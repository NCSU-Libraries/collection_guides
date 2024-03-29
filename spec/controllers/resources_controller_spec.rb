require 'rails_helper'

DatabaseCleaner.start

describe ResourcesController, :type => :controller do

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_successful
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      r = create(:resource)
      get :show, params: { :id => r.id }
      expect(response).to be_successful
      expect(response.status).to eq(200)
    end
  end

end

DatabaseCleaner.clean
