module LinkHelper

  def link_options_for_select(selected, options={})
    selects = []
    if !options[:include_blank].blank?
      options[:include_blank] = "" if options[:include_blank] == true
      selects << [options[:include_blank].to_s, [nil]]
    end
    for model in EskimoLinks.all_models
      group = [model.to_s.underscore.humanize.pluralize.titleize, []]
  		for object in model.send("unrecycled").sort_by{|x| x.name}
    		name = (object.name.length > 50) ? "#{object.name[0..50]}..." : object.name
  			group[1] << [name, url_for(object)]
  		end
  		selects << group
    end
    grouped_options_for_select(selects, selected)
  end

end
