module ApplicationHelper

  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TagHelper
  include DescriptionHelper
  include GeneralUtilities

  def collection_guide_path_from_resource_uri(uri)
    if uri.match(/^\/repositories\/\d+\/resources\/\d+$/)
      path = uri.clone
      path.gsub(/^\/repositories\/\d+/,'')
    else
      ''
    end
  end


  def show_test_data(data, id)
    if Rails.env == 'development'
      output = ''
      output << "<a href=\"#\" data-reveal-id=\"dataModal-#{id}\" class=\"button tiny show-test-data\">DEVELOPMENT - Show raw data</a>"
      output << "<div id=\"dataModal-#{id}\" class=\"reveal-modal test-data-modal\" data-reveal>"
      output << data.inspect
      output << '</div>'
      output.html_safe
    end
  end


  def show_hide_block(text, options={})
    truncate_length = 400
    css_class = options[:class]
    content = ''
    if truncate?(text, truncate_length)
      css_class += ' show-more'
      content << '<div class="text-short">'
      content << truncate_html(text, length: truncate_length,  omission: ' ... <a class="trigger"><i class="fa fa-caret-down"></i> More</a>')
      content << '</div>'
      content << '<div class="text-long hidden">'
      content << text
      content << ' <a class="trigger less"><i class="fa fa-caret-up"></i> Less</a>'
      content << '</div>'
    else
      content << text
    end
    content_tag(:div, content.html_safe, class: css_class)
  end


  def truncate?(string, max_length)
    eval_string = string.clone
    eval_string = strip_tags(eval_string)
    eval_string.length > max_length
  end


  def agent_search_link(agent)
    path = searches_path(agent_id: agent[:id])
    link_to(agent[:display_name].html_safe, path)
  end


  def subject_search_link(subject)
    path = searches_path(subject_id: subject[:id])
    link_to(subject[:subject].html_safe, path)
  end


  def escaped_fragment_meta
    if @resource && @resource.total_components && @resource.total_components > 1000
      '<meta name="fragment" content="!">'.html_safe
    end
  end


  def user_agent
    request.headers['HTTP_USER_AGENT']
  end


  # only checks for Google or Bing
  def user_agent_is_search_bot
    bot_strings = [ /googlebot/i, /bingbot/i ]
    agent = user_agent
    is_bot = false
    bot_strings.each do |b|
      if agent.match(b)
        is_bot = true
        break
      end
    end
    is_bot
  end


  # Load custom methods if they exist
  begin
    include ApplicationHelperCustom
  rescue
  end

end
