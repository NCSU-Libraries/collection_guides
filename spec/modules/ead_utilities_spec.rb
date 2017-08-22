require 'spec_helper'
include EadUtilities

describe EadUtilities do

  #convert_ead_elements(xml)
  
  it "converts inline EAD tags to spans" do
    xml = "<title>title</title> <persname>persname</persname> <archref>archref</archref>"
    expected = '<span class="title">title</span> <span class="persname">persname</span> <span class="archref">archref</span>'
    expect(convert_ead_elements(xml)).to eq(expected)
  end


  it "converts block-level EAD tags to divs and leaves common elements unchanged" do
    xml = "<note><div><p>note</p></div></note><bioghist><p>bioghist</p></bioghist>"
    expected = '<div class="note"><div><p>note</p></div></div><div class="bioghist"><p>bioghist</p></div>'
    expect(convert_ead_elements(xml)).to eq(expected)
  end

  it "converts extref to a, retaining attributes that are common to HTML" do
    xml = '<extref href="href" id="id" acctuate="onRequest">link</extref>'
    expected = '<a href="href" id="id" data-acctuate="onRequest" class="extref">link</a>'
    expect(convert_ead_elements(xml)).to eq(expected)
  end

  it "converts emph and lb to html equivalents" do
    xml = '<emph>x</emph><lb>'
    expected = '<em>x</em><br>'
    expect(convert_ead_elements(xml)).to eq(expected)
  end

  it "converts lists to html" do
    xml = '<list type="ordered" numeration="arabic"><item>item</item><item>item</item></list>'
    expected = '<ol type="1" class="list"><li class="item">item</li><li class="item">item</li></ol>'
    expect(convert_ead_elements(xml)).to eq(expected)
    xml = '<list><item>item</item><item>item</item></list>'
    expected = '<ul class="list"><li class="item">item</li><li class="item">item</li></ul>'
    expect(convert_ead_elements(xml)).to eq(expected)
    xml = '<chronlist><chronitem><date>1999</date><event>Event</event></chronitem></chronlist>'
    expected = '<ul class="chronlist"><li class="chronitem"><span class="date">1999</span><span class="event">Event</span></li></ul>'
    expect(convert_ead_elements(xml)).to eq(expected)
  end

end