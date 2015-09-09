module EskimoLinks

  def self.models
    PageNode.models.collect{|pn| pn.model.camelcase.constantize}.uniq 
  end
  
  def self.all_models
    self.models << PageNode
  end
  
  def self.models_for_select
    ret = []
    for model in self.models
    ret << [model.to_s.underscore.humanize.pluralize.titleize, model.to_s]
    end
    ret
  end
  
  def self.objects
    ret = []
      for model in self.models
    		for object in model.send("unrecycled").sort_by{|x| x.name}
    			ret << object
    		end
      end
    ret
  end
  
  ActionView::Base.send :include, LinkHelper

end
