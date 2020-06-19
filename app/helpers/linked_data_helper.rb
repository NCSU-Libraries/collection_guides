module LinkedDataHelper

  include ApplicationHelper

  def ld_provider
    html = '<span property="schema:provider arch:heldBy"
      resource="http://www.lib.ncsu.edu/ld/onld/00000658"></span>'
    html.html_safe
  end

end
