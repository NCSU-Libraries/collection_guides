require 'spec_helper'
include AspaceContentUtilities

describe AspaceContentUtilities do

  # parse_chronlist_note(note)
  it "parses a chronlist sub-note into HTML" do
    note = chronlist_subnote
    expected = chronlist_subnote_expected
    expect(parse_chronlist_note(note)).to eq(expected)
  end

  # parse_ordered_list_note(note)
  it "parses an ordered list sub-note into HTML" do
    note = ordered_list_subnote
    expected_html = ordered_list_subnote_expected
    expect(parse_ordered_list_note(note)).to eq(expected_html)
  end

  # parse_deflist_note(note)
  it "parses a deflist list sub-note into HTML" do
    note = deflist_subnote
    expected_html = deflist_subnote_expected
    expect(parse_deflist_note(note)).to eq(expected_html)
  end

  # parse_text_note(note)
  it "parses a text sub-note into HTML" do
    note = text_subnote
    expected_html = text_subnote_expected
    expect(parse_text_note(note)).to eq(expected_html)
  end

  # parse_notes(api_response)
  it "parses notes into a structured hash organized by note type" do
    expect(parse_notes(mixed_notes).with_indifferent_access).to eq(parse_mixed_notes_expected.with_indifferent_access)
  end

  # add_paragraphs(content)
  it "adds paragraphs to multi-line text but leaves blockquotes" do
    input = "First paragraph.\n\n<blockquote>Quote</blockquote>\n\nSecond paragraph."
    expected = "<p>First paragraph.</p><blockquote>Quote</blockquote><p>Second paragraph.</p>"
    expect(add_paragraphs(input)).to eq(expected)
  end

  it "generates extent statement for one extent with container summary" do
    expect(generate_extent_statement(mixed_extent)).to eq(mixed_extent_expected)
  end

  it "generates extent statement from multiple extents" do
    extents = [
      { "number"=>"55", "container_summary"=>"88 letter boxes\n1 legal box\n7 cartons", "created_by"=>"admin",
        "portion"=>"whole", "extent_type"=>"linear_feet" }
    ]
    expected = "55 linear feet (88 letter boxes, 1 legal box, 7 cartons)"
    expect(generate_extent_statement(extents)).to eq(expected)
  end

  it "sorts dates by label attribute" do
    dates = [
      { "begin"=>"1960", "date_type"=>"single", "label"=>"creation" },
      { "begin"=>"1970", "date_type"=>"single", "label"=>"creation" },
      { "begin"=>"1960", "date_type"=>"single", "label"=>"copyright" },
      { "begin"=>"1960", "date_type"=>"single", "label"=>"issued" }
    ]
    expected = { 'creation' => [dates[0], dates[1]], 'copyright' => [dates[2]], 'issued' => [dates[3]] }
    expect(sort_dates_by_label(dates)).to eq(expected)
  end

  it "generates a date statement from creation dates, combining inclusive and bulk dates" do
    dates = [
      { "expression"=> "", "begin"=>"1960", "end"=>"1999", "date_type"=>"inclusive", "label"=>"creation" },
      { "begin"=>"1970", "end"=>"1979", "date_type"=>"bulk", "label"=>"creation" },
      { "begin"=>"1960", "date_type"=>"single", "label"=>"copyright" },
      { "begin"=>"1960", "date_type"=>"single", "label"=>"issued" }
    ]
    expected = '1960-1999 (bulk 1970-1979)'
    expect(generate_date_statement(dates)).to eq(expected)
  end

  it "generates a date statement from a combination of ranges and non-consecutive dates" do
    dates = [
      { "begin"=>"1960", "end"=>"1965", "date_type"=>"range", "label"=>"creation" },
      { "begin"=>"1970", "end"=>"1979", "date_type"=>"range", "label"=>"creation" },
      { "begin"=>"1982", "date_type"=>"single", "label"=>"creation" },
      { "begin"=>"1989", "date_type"=>"single", "label"=>"creation" }
    ]
    expected = '1960-1965, 1970-1979, 1982, 1989'
    expect(generate_date_statement(dates)).to eq(expected)
  end

end
