require 'spec_helper'
require 'solr_sanitizer'

describe SolrSanitizer do

  it "sanitizes strings" do
     dirty_string = "\",x:window.top._arachni_js_namespace_taint_tracer.log_execution_flow_sink(),y:\""
     clean_string = ",x window.top._arachni_js_namespace_taint_tracer.log_execution_flow_sink ,y"
     expect(SolrSanitizer.sanitize_query_string(dirty_string)).to eq(clean_string)
  end


  it "sanitizes strings with integer values" do
    dirty_string = "174'gjwbl\"uzi"
    clean_string = "174"
    expect(SolrSanitizer.sanitize_integer(dirty_string)).to eq(clean_string)
  end


  it "sanitizes numeric range string" do
    good_range = "[123 TO 234]"
    bad_range = "[123 TO 1STEALYOURP$$W0RD]"
    expect(SolrSanitizer.sanitize_numeric_range(good_range)).to eq(good_range)
    expect(SolrSanitizer.sanitize_numeric_range(bad_range)).to be_nil
  end

end
