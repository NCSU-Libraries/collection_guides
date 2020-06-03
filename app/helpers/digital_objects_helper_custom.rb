module DigitalObjectsHelperCustom

  include ApplicationHelper
  include ActionView::Helpers::UrlHelper


  def get_digital_object_url(digital_object)
    url = nil
    if digital_object[:files]
      digital_object[:files].each do |file|
        if file[:file_uri] =~ /d\.lib\.ncsu\.edu/
          url = file[:file_uri]
          if !(url.match(/^http/))
            url = 'https://' + url
          end
          break
        end
      end
    end
    url
  end

end
