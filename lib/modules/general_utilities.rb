module GeneralUtilities

  include ActiveSupport::Inflector

  def self.included receiver
    receiver.extend self
  end

  def cleanup_newlines(string)
    string.gsub!(/[\n\r]+/,"\n")
    string
  end

  def remove_blank_values(hash)
    hash.each do |k,v|
      if v.blank?
        hash.delete(k)
      elsif v.kind_of? Hash
        v.remove_blank_values
      end
    end
    hash
  end


  def escape_ampersands(string)
    string.gsub!(/\&(?![\#a-z\d]{2,6}\;)/i,'&amp;')
    string
  end


  def remove_newlines(string)
    string.gsub!(/[\n\r]+\s*/, ' ')
    remove_extra_whitespace(string)
  end


  def remove_extra_whitespace(string)
    string.gsub!(/[\s]+/, ' ')
    string.gsub!(/\s\<\//, '</')
    string.gsub!(/\s\.\s?$/, '.')
    string.gsub!(/\s\,\s/, ', ')
    string.strip!
    string
  end


  def clean_inner_text(text)
    text.strip!
    text.gsub!(/\s{2,}/,' ')
    if text.match(/^\(/) && text.match(/\)$/)
      text.gsub!(/^\(/, '')
      text.gsub!(/\)$/, '')
    end
    remove_newlines(text)
  end


  # remove hash elements with blank values (recursive)
  # values explicitly set to false will not be removed
  def compact(hash)
    hash.each do |k,v|
      if v.kind_of?(Hash)
        compact(v)
      elsif v.kind_of?(Array)
        v.each do |av|
          if av.kind_of?(Hash)
            compact(av)
          end
          if av.blank? && !(av === false)
            v.delete_at(v.index(av))
          end
        end
      end
    end
    hash.delete_if { |k,v| v.blank? && !(v === false) }
    hash
  end


  def number_to_text(number)
    get_digits = lambda do |number|
      digits = []
      string = number.to_s
      for i in 0..(string.length - 1)
        digits << string[i].to_i
      end
      return digits
    end
    ones = ['zero','one','two','three','four','five','six','seven','eight','nine']
    teens = ['ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen']
    multiples_of_ten = ['','ten','twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety']

    digits = get_digits.call(number)

    if number < 10
      ones[number]
    elsif number.between?(10,19)
      teens[number - 10]
    elsif number.between?(20,99)
      digits = get_digits.call(number)
      text = multiples_of_ten[digits[0]]
      if digits[1] != 0
        text += "-#{ones[digits[1]]}"
      end
      text
    elsif number == 100
      'one hundred'
    else
      number.to_s
    end
  end


  # convert an array of integers (eg years expressed as integers) to a standardized string
  #   containing a combination of ranges and singletons
  def integer_array_to_string(array)
    array.sort!
    string = ''
    array.each_index do |i|
      if i == 0
        string += array[i].to_s
      else
        prev_x = array[i - 1]
        next_x = array[i + 1]
        this_x = array[i]
        if (this_x == prev_x + 1) && (next_x == this_x + 1)
          next
        elsif (this_x == prev_x + 1) && (next_x != this_x + 1)
          string += "-" + this_x.to_s
        elsif (this_x != prev_x + 1)
          string += ", " + this_x.to_s
        end
      end
    end
    string
  end


  def slugify(string)
    string.downcase.gsub(/[\-\.]+/,'_').gsub(/[^A-Za-z0-9_]/,'')
  end


  def number_to_text(number)
    get_digits = lambda do |number|
      digits = []
      string = number.to_s
      for i in 0..(string.length - 1)
        digits << string[i].to_i
      end
      return digits
    end
    ones = ['zero','one','two','three','four','five','six','seven','eight','nine']
    teens = ['ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen']
    multiples_of_ten = ['','ten','twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety']

    digits = get_digits.call(number)

    if number < 10
      ones[number]
    elsif number.between?(10,19)
      teens[number - 10]
    elsif number.between?(20,99)
      digits = get_digits.call(number)
      text = multiples_of_ten[digits[0]]
      if digits[1] != 0
        text += "-#{ones[digits[1]]}"
      end
      text
    elsif number == 100
      'one hundred'
    else
      number.to_s
    end
  end


  def log_info(message)
    Rails.logger.info message
    puts "#{DateTime.now.to_s} - #{message}"
  end

end
