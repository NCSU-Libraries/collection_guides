require 'spec_helper'

DatabaseCleaner.start

describe Presentation do

  it "is instantiated by a resource using the presneter method" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    p = r.presenter
    expect(p).to be_a_kind_of(Presentation::Presenter)
  end

  it "provides parsed notes" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    p = r.presenter
    notes_expected = parse_mixed_notes_expected.clone

    notes_expected.delete("abstract")

    expect(p.notes).to eq(notes_expected)
  end


  it "provide title, uri, abstract, date statement, extent statement, collection id" do
    r = create(:resource, :api_response => JSON.generate(test_response_data[:resource]) )
    p = r.presenter
    expect(p.title).to eq(r.title)
    expect(p.uri).to eq(r.uri)
    expect(p.abstract).to eq("<p>This is the abstract!</p>")
    expect(p.date_statement).to eq(date_statement_expected)
    expect(p.extent_statement).to eq(mixed_extent_expected)
    expect(p.collection_id).to eq("TEST1234")
  end


  it "provides containers" do
    a = create(:archival_object)
    p = a.presenter
    expect(p.containers).to eq(['Box 1, Folder 1'])
  end



end

DatabaseCleaner.clean
