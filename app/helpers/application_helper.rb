# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def hide_news
    @hide_news = true
  end
  
  def hide_news?
    @hide_news
  end
	
	def determine_page_node
		if @page_node
			@current_page_node = @page_node
		elsif PageNode.controller_action(params[:controller], params[:action]).first
			@current_page_node = PageNode.controller_action(params[:controller], params[:action]).sort_by{|x| x.position}.first
		elsif PageNode.controller_action(params[:controller], "").first
			@current_page_node = PageNode.controller_action(params[:controller], "").sort_by{|x| x.position}.first
		else
			nil
		end
	end
	
  def toggle_fieldset(legend, name=nil, open=false)
    name ||= legend.downcase.gsub(/\W/, '_')
    ret = ""
    ret += "<fieldset style=\"height:0px; #{open ? "display:none;" : ""}\" id=\"#{name}_1\">"
	  ret += "<legend style=\"cursor:pointer;cursor:hand\" onclick=\"$('#{name}_1').toggle(); $('#{name}_2').toggle();\">#{legend}</legend>"
    ret += "</fieldset>"
    ret += "<fieldset id=\"#{name}_2\" style=\"#{open ? "" : "display:none;"}\">"
	  ret += "<legend style=\"cursor:pointer;cursor:hand\" onclick=\"$('#{name}_1').toggle(); $('#{name}_2').toggle();\">#{legend}</legend>"
	  ret
  end
  
end
