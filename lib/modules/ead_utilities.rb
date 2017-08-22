module EadUtilities

  def list_type_to_ol_type(type)
    types = {
      'arabic' => '1',
      'loweralpha' => 'a',
      'lowerroman' => 'i',
      'upperalpha' => 'A',
      'upperroman' => 'I'
    }
    types[type]
  end


  def convert_ead_elements(xml)

    common_elements = ['p','blockquote','div']
    block_elements = ['note','address','bioghist','scopecontent','arrangement']
    inline_elements = ['abbr','addressline','archref','bibref','bibseries','date',
      'edition','event','expan','imprint','num','subarea','persname','famname','corpname',
      'genreform','geogname','name','subject','title','occupation']
    list_elements = ['chronlist','list']
    list_content_elements = ['chronitem','eventgrp','item','defitem']
    remove_elements = ['extptr', 'ptr', 'ref', 'head', 'head01', 'head02']

    doc = Nokogiri::XML("<ead_content>#{xml}</ead_content>")
    doc.remove_namespaces!

    root = doc.root

    convert_attributes = Proc.new do |element|
      html_attributes = ['href','id','title']
      element.attributes.each do |k,v|
        # pesky namespaces in AS response data!
        if k.match(/\:/)
          attribute_name = k.gsub(/^[^\:]*\:/,'')
          element[attribute_name] = v
          element.remove_attribute(k)
        else
          attribute_name = k
        end

        if element.name == 'list' && attribute_name == 'numeration'
          element['type'] = list_type_to_ol_type(v.to_s)
          element.remove_attribute(k)
        elsif !html_attributes.include?(attribute_name)
          element["data-#{attribute_name}"] = v
          element.remove_attribute(k)
        end
      end
      element['class'] = element.name
    end

    root.xpath('//*').each do |e|

      if !common_elements.include?(e.name)

        if block_elements.include?(e.name)
          convert_attributes.call(e)
          e.name = 'div'

        elsif inline_elements.include?(e.name)
          convert_attributes.call(e)
          e.name = 'span'

        elsif e.name == 'extref'
          convert_attributes.call(e)
          e.name = 'a'

        # catch emph and convert to em
        elsif e.name == 'emph'
          e.name = 'em'

        elsif e.name == 'lb'
          e.name = 'br'

        elsif remove_elements.include?(e.name)
          e.replace(e.inner_html)

        elsif list_elements.include?(e.name)
          type = e['type']
          e.remove_attribute('type')
          convert_attributes.call(e)
          e.name = (type == 'ordered') ? 'ol' : 'ul'

          # process list content elements only if children of list elements
          e.element_children.each do |ee|
            if list_content_elements.include?(ee.name)
              convert_attributes.call(ee)
              case ee.name
              when 'chronitem','item','defitem'
                ee.name = 'li'
              when 'date','event'
                ee.name = 'span'
              when 'eventgrp'
                ee.name = 'div'
              end
            end
          end
        else

        end
      end
    end
    html = root.inner_html.to_s
    # remove newlines between tags
    html.gsub(/\>\n*\</,'><')
  end

end
