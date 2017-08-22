module EadExportDates

  def did_add_dates(did, data)
    dates = data['dates']
    date_elements = []

    # One date
    if dates.length == 1
      date_data = dates.first

      if date_data['expression']
        unitdate = create_element('unitdate', date_data['expression'])
        add_unitdatetype(date_data, unitdate)
        date_elements << unitdate
      end

      structure = get_date_structure(date_data)
      if [:range, :single].include? structure
        unitdatestructured = create_element('unitdatestructured')
        subelement = structure == :range ? create_daterange(date_data) : create_datesingle(date_data)
        unitdatestructured << subelement
        add_unitdatetype(date_data, unitdatestructured)
        date_elements << unitdatestructured
      end

    # Multiple dates
    else
      dates_categorized = {}

      dates.each do |d|
        if d['expression']
          unitdate = create_element('unitdate', d['expression'])
          add_unitdatetype(d, unitdate)
          date_elements << unitdate
        end
        structure = get_date_structure(d)
        if structure
          (dates_categorized[structure] ||= []) << { data: d, position: dates.index(d) }
        end
      end

      if dates_categorized[:range] || dates_categorized[:single]
        unitdatestructured = create_element('unitdatestructured')
        if dates_categorized[:range] && dates_categorized[:single]
          date_data_array = []
          (dates_categorized[:range] + dates_categorized[:single]).each do |d|
            date_data_array[d[:position]] = d[:data]
          end
        elsif dates_categorized[:range]
          date_data_array = dates_categorized[:range].map { |d| d[:data] }
        elsif dates_categorized[:single]
          date_data_array = dates_categorized[:single].map { |d| d[:data] }
        end
        unitdatestructured << create_dateset(date_data_array)
      end

    end

    date_elements.each do |date_element|
      did << date_element
    end

  end


  def add_unitdatetype(date_data, date_element)
    if ['bulk','inclusive'].include?(date_data['type'])
      element['unitdatetype'] = date_data['type']
    end
  end


  def get_date_structure(date_data)
    if date_data['begin'] && date_data['end']
      :range
    elsif date_data['begin'] && date_data['date_type'] == 'single'
      :single
    elsif date_data['begin'] || date_data['end']
      :range
    else
      nil
    end
  end


  def create_datesingle(date_data)
    create_element('datesingle', date_data['begin'])
  end


  def create_daterange(date_data)
    daterange = create_element('daterange')
    if date_data['begin']
      daterange << create_element('fromdate', date_data['begin'])
    end
    if date_data['end']
      daterange << create_element('todate', date_data['end'])
    end
    daterange
  end


  def create_dateset(date_data_array)
    dateset = create_element('dateset')
    date_data_array.each do |date_data|
      case get_date_structure(date_data)
      when :range
        dateset << create_daterange(date_data)
      when :single
        dateset << create_datesingle(date_data)
      end
    end
    dateset
  end

end
