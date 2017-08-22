class Object
  
  def deeper_symbolize_keys!
    case self
    when Hash
      self.symbolize_keys!
      self.each do |k,v|
        case v
        when Hash
          v.deeper_symbolize_keys!
        when Array
          v.each { |x| x.deeper_symbolize_keys! }
        else
          self
        end
      end
    else
      self
    end
  end

  def deeper_symbolize_keys
    case self
    when Hash
      new_hash = self.clone
      new_hash.deeper_symbolize_keys!
    else
      self
    end
  end

end