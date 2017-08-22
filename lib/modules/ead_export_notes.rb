module EadExportNotes

  def add_note(note_name, parent_element, notes_data)
    case note_name
    when 'didnote'
      note_name = 'note'
      element_name = 'didnote'
    else
      element_name = note_name
    end

    if notes_data[note_name.to_sym]
      notes_data[note_name.to_sym].each do |note|
        parent_element << create_element(element_name, note[:content])
      end
    end
  end


  def parse_notes(notes)
    parsed_notes = {}
    remove_unpublished(notes)
    notes.each_index do |i|
      n = notes[i]
      note = { content: '', position: i }
      note[:label] = n['label'] if n['label']
      case n['jsonmodel_type']
      when "note_singlepart"
        note[:content] << parse_simple_text_note(n)
      when "note_multipart"
        n['subnotes'].each do |nn|
          case nn['jsonmodel_type']
          when 'note_text'
            note[:content] << parse_mixed_content_text_note(nn)
          when 'note_chronology'
            note[:content] << parse_chronlist_note(nn)
          when 'note_definedlist'
            note[:content] << parse_deflist_note(nn)
          when 'note_orderedlist'
            note[:content] << parse_ordered_list_note(nn)
          end
        end
      end
      note_type = n['type'] || n['jsonmodel_type']
      (parsed_notes[note_type.to_sym] ||= []) << note
    end
    parsed_notes
  end


  def parse_chronlist_note(note)
    list_content = ''
    note['items'].each do |item|
      list_content += '<chronitem>'
      list_content += "<datesingle>#{item['event_date']}</datesingle>"
      events = ''
      item['events'].each do |e|
        events << "<event>#{remove_xml(e)}</event>"
      end
      list_content += (item['events'].length > 1) ? "<eventgrp>#{events}</eventgrp>" : events
      list_content += '</chronitem>'
    end
    !list_content.empty? ? "<chronlist>#{list_content}</chronlist>" : ''
  end


  def parse_ordered_list_note(note)
    list = ''
    items = note['items']
    if !items.empty?
      if note['enumeration'] && !note['enumeration'].blank? && note['enumeration'] != 'null'
        list += "<list numeration=\"#{note['enumeration']}\">"
      else
        list += '<list>'
      end
      items.each { |item| list += "<item>#{remove_xml(item)}</item>" }
      list += '</list>'
    end
    list
  end


  def parse_simple_text_note(note)
    text = ''
    if note['content'].kind_of? Array
      note['content'].each { |c| text << remove_block_elements(c) }
    else
      text << remove_block_elements(note['content'])
    end
    remove_xml(text)
  end


  def remove_block_elements(string)
    new_string = string.clone
    new_string.gsub!(/\<\/p\>/,' ')
    new_string.gsub!(/\<\/blockquote\>/,' ')
    new_string.gsub!(/(\<p\>)|(\<blockquote\>)/,'')
    new_string
  end


  def parse_mixed_content_text_note(note)
    output = ''
    if note['content'].kind_of? Array
      note['content'].each { |c| output << add_paragraphs(remove_xml(c)) }
    else
      output << add_paragraphs(remove_xml(note['content']))
    end
    remove_xml_attributes(output)

  end


  def parse_deflist_note(note)
    list = ''
    items = note['items']
    if !items.empty?
      list += '<list listype="deflist">'
      items.each { |item| list << "<defitem><label>#{item['label']}</label><item>#{remove_xml(item['value'])}</item></defitem>" }
      list += '</list>'
    end
    remove_xml_attributes(list)
  end


  # Adds paragraphs to text content divided by multiple line breaks
  # Returns modified string, leaving original unchanged
  def add_paragraphs(content)
    s = content.clone
    s.strip!
    # don't do anything unless there are line breaks
    # check for blockquote and remove spaces between blockquote and p if present
    if s.match(/\<blockquote\>/)
      s.gsub!(/\<blockquote\>\s*\n*\<p\>/,"<blockquote><p>")
      s.gsub!(/\<\/p\>\s*\n*\<\/blockquote\>/,"</p></blockquote>")
    end

    # remove existing divs and paragraphs
    # except inside <blockquote>
    s.gsub!(/(?<!\<blockquote\>)\<((p)|(div))\>/,'')
    s.gsub!(/\<\/((p)|(div))\>(?!\<\/blockquote\>)/,'')

    # wrap content in paragraph
    s.prepend("<p>")
    s << "</p>"

    # replace double line breaks with close/start paragraph
    s.gsub!(/\n{2,}/,"</p><p>")

    # blockquotes are now wrapped in a p, which is wrong, so fix that
    s.gsub!(/\<p\>\<blockquote\>/,"<blockquote>")
    s.gsub!(/\<\/blockquote\>\<\/p\>/,"</blockquote>")
    s
  end


  def remove_xml_attributes(xml)
    doc = Nokogiri::XML("<ead_content>#{xml}</ead_content>")
    doc.remove_namespaces!
    root = doc.root
    root.xpath('//*').each do |e|
      e.attributes.each do |k,v|
        e.remove_attribute(k)
      end
    end
    return_content = root.inner_html.to_s
    # remove newlines between tags
    return_content.gsub(/\>\n*\</,'><')
  end


  def remove_xml(string)
    tag_regex = /\<[^\>]*\>/
    string.gsub!(tag_regex,'')
    string
  end

end
