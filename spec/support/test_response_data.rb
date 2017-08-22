module TestResponseData

  def test_response_data
    {
      resource: {
        "title"=>"Test resource",
        "id_0"=>"TEST1234",
        "language"=>"eng",
        "level"=>"collection",
        "extents"=> mixed_extent,
        "dates"=>[
          { "expression"=>"1960 - 1999", "begin"=>"1960", "end"=>"1999", "date_type"=>"inclusive", "label"=>"creation", "jsonmodel_type"=>"date"},
          {"lock_version"=>0, "begin"=>"1970", "end"=>"1979", "date_type"=>"bulk", "label"=>"creation", "jsonmodel_type"=>"date"}
        ],
        "notes"=> mixed_notes,
        "linked_agents" => linked_agents,
        "uri"=>"/repositories/2/resources/13013"
      },

      archival_object: {
        "position"=>0,
        "publish"=>true,
        "title"=>"Test component",
        "display_string"=>"Test component, 1982-10-01",
        "restrictions_apply"=>false,
        "suppressed"=>false,
        "language"=>"eng",
        "level"=>"series",
        "jsonmodel_type"=>"archival_object",
        "extents"=>[
          { "number"=>"2", "portion"=>"whole", "extent_type"=>"folder" }
        ],
        "dates"=>[
          { "begin"=>"1982-10-01", "date_type"=>"single", "label"=>"creation", "jsonmodel_type"=>"date"}
        ],
        "instances"=>[
          { "instance_type"=>"mixed_materials", "jsonmodel_type"=>"instance",
            "container"=> { "indicator_1"=>"1", "type_1"=>"box", "indicator_2"=>"1", "type_2"=>"folder", "jsonmodel_type"=>"container", "container_locations"=>[]}
          }
        ],
        "notes"=>[
          {"jsonmodel_type"=>"note_multipart", "type"=>"scopecontent",
            "subnotes"=> [
              {"jsonmodel_type"=>"note_text", "content"=>"First paragraph", "publish"=>true}
            ],
            "publish"=>true}
        ],
        "uri"=>"/repositories/2/archival_objects/333484",
        "repository"=>{"ref"=>"/repositories/2"},
        "resource"=>{"ref"=>"/repositories/2/resources/1317"},
        "has_unpublished_ancestor"=>false
      }

    }
  end


  def linked_agents
    [
      {"role"=>"creator", "ref"=>"/agents/people/2484", "_resolved"=>
        { "publish"=>true, "jsonmodel_type"=>"agent_person", "linked_agent_roles"=>["creator", "subject"], "names"=>[
          { "primary_name"=>"Trevor Thornton", "sort_name"=>" Trevor Thornton", "sort_name_auto_generate"=>true,
            "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"local", "name_order"=>"direct", "jsonmodel_type"=>"name_person", "use_dates"=>[]}
        ], "uri"=>"/agents/people/2484", "agent_type"=>"agent_person", "display_name"=>
          { "primary_name"=>"Trevor Thornton", "sort_name"=>" Trevor Thornton", "sort_name_auto_generate"=>true,
            "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"local", "name_order"=>"direct", "jsonmodel_type"=>"name_person", "use_dates"=>[]},
        "title"=>" Trevor Thornton", "is_linked_to_published_record"=>true}
        },
      {"role"=>"source", "terms"=>[], "ref"=>"/agents/people/2488", "_resolved"=>
        { "publish"=>true, "jsonmodel_type"=>"agent_person", "agent_contacts"=>[], "linked_agent_roles"=>["creator", "source"], "names"=>
          [ { "primary_name"=>"Doe", "rest_of_name"=>"Jane", "sort_name"=>"Doe, Jane", "sort_name_auto_generate"=>true,
            "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted", "jsonmodel_type"=>"name_person", "use_dates"=>[]}
          ],
          "uri"=>"/agents/people/2488", "agent_type"=>"agent_person", "display_name"=>
          { "primary_name"=>"Doe", "rest_of_name"=>"Jane", "sort_name"=>"Doe, Jane", "sort_name_auto_generate"=>true,
            "authorized"=>true, "is_display_name"=>true, "source"=>"local", "rules"=>"aacr", "name_order"=>"inverted", "jsonmodel_type"=>"name_person", "use_dates"=>[]},
          "title"=>"Doe, Jane", "is_linked_to_published_record"=>true
        }
      }
    ]
  end


  def mixed_extent
    [
      { "number"=>"55", "container_summary"=>"88 letter boxes\n1 legal box\n7 cartons", "created_by"=>"admin",
        "portion"=>"whole", "extent_type"=>"linear_feet" }
    ]
  end

  def mixed_extent_expected
    "55 linear feet (88 letter boxes, 1 legal box, 7 cartons)"
  end

  def date_statement_expected
    "1960-1999 (bulk 1970-1979)"
  end

  def test_response(type)
    JSON.generate(test_response_data[type])
  end

  def mixed_notes
    [abstract_note, scope_content_note, bioghist_note_with_test_and_chronlist]
  end

  def parse_mixed_notes_expected
    {
      "abstract" => [ {"content" => "<p>This is the abstract!</p>", "position" => 0} ],
      "scopecontent" => [ {"content" => text_subnote_expected, "position" => 1} ],
      "bioghist" => [ {"content" => "#{text_subnote_expected}#{chronlist_subnote_expected}", "position" => 2} ]
    }
  end

  def abstract_note
    {"jsonmodel_type"=>"note_singlepart", "type"=>"abstract", "content"=>["This is the abstract!"], "publish"=>true}
  end

  def scope_content_note
    {"jsonmodel_type"=>"note_multipart", "type"=>"scopecontent", "subnotes"=>[text_subnote], "publish"=>true}
  end

  def bioghist_note_with_test_and_chronlist
    {"jsonmodel_type"=>"note_multipart", "type"=>"bioghist", "subnotes"=>[text_subnote, chronlist_subnote], "publish"=>true}
  end

  def singlepart_text_note
    abstract_note
  end

  def multipart_text_note
    scope_content_note
  end

  def chronlist_note
    {"jsonmodel_type"=>"note_multipart", "type"=>"bioghist", "subnotes"=>[chronlist_subnote], "publish"=>true}
  end


  def ordered_list_note
    {"jsonmodel_type"=>"note_multipart", "label"=>"Note label", "type"=>"odd", "subnotes"=>[ordered_list_subnote], "publish"=>true}
  end

  def deflist_note
    {"jsonmodel_type"=>"note_multipart", "label"=>"Note label", "type"=>"odd", "subnotes"=>[deflist_subnote], "publish"=>true}
  end

  def chronlist_subnote
    {"jsonmodel_type"=>"note_chronology", "publish"=>true, "items"=>[
      {"event_date"=>"1960", "events"=>["Event 1", "Event 2"]},
      {"event_date"=>"1970", "events"=>["Event 1", "Event 2"]}
    ]}
  end

  def chronlist_subnote_expected
    expected = '<div class="chronlist">'
    expected << '<div class="chronitem row"><div class="date">1960</div>'
    expected << '<div class="events"><div class="event">Event 1</div><div class="event">Event 2</div></div>'
    expected << '</div>'
    expected << '<div class="chronitem row"><div class="date">1970</div>'
    expected << '<div class="events"><div class="event">Event 1</div><div class="event">Event 2</div></div>'
    expected << '</div>'
    expected << '</div>'
  end

  def deflist_subnote
    {"jsonmodel_type"=>"note_definedlist", "title"=>"List title", "publish"=>true, "items"=>[
        {"label"=>"Label 1", "value"=>"Value 1"}, {"label"=>"Label 2", "value"=>"Value 2"}
    ]}
  end

  def deflist_subnote_expected
    '<dl><dt>Label 1</dt><dd>Value 1</dd><dt>Label 2</dt><dd>Value 2</dd></dl>'
  end

  def ordered_list_subnote
    {"jsonmodel_type"=>"note_orderedlist", "title"=>"List title", "enumeration"=>"arabic", "publish"=>true,
      "items"=>["Item 1", "Item 2"]
    }
  end

  def ordered_list_subnote_expected
    '<ol type="1"><li>Item 1</li><li>Item 2</li></ol>'
  end

  def text_subnote
    {"jsonmodel_type"=>"note_text", "content"=>"First paragraph.\n\nSecond paragraph.", "publish"=>true}
  end

  def text_subnote_expected
    '<p>First paragraph.</p><p>Second paragraph.</p>'
  end



end
