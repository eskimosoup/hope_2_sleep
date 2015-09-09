class Product < ActiveRecord::Base
	
	acts_as_eskimagical :recycle => true

  has_many :reviews
	has_many :variations, :dependent => :destroy
	has_and_belongs_to_many :associated_products, :class_name => "Product", :join_table => "product_associations", :foreign_key => "first_product_id", :association_foreign_key => "second_product_id"
	has_and_belongs_to_many :promo_codes
	
	has_attached_image :image_1, :styles => {:index => "114x114#", :highlight => "283x283#"}
	has_attached_image :image_2, :styles => {:index => "114x114#", :highlight => "283x283#"}
	has_attached_image :image_3, :styles => {:index => "114x114#", :highlight => "283x283#"}
	has_attached_image :image_4, :styles => {:index => "114x114#", :highlight => "283x283#"}
	has_images
	
	may_contain_images [:summary]
	
	validates_presence_of :name, :weight
	validates_format_of :price, :with => /^\d+(\.\d{1,2})?$/
	validates_numericality_of :weight, :only_integer => true, :greater_than_or_equal_to => 0
  
	named_scope :position, :order => "products.position"
  named_scope :active, :conditions => ["products.recycled = ? AND products.display = ? AND variations.product_id", false, true], :include => "variations"
  named_scope :recycled, :conditions => ["products.recycled = ?", true]
  named_scope :unrecycled, :conditions => ["products.recycled = ?", false]
  
  named_scope :latest, :order => "products.created_at DESC"
  
  before_save :nullify_variation_options
  
  def nullify_variation_options
    for variation in variations
      if option_1_name.blank?
        variation.update_attribute(:option_1, nil)
      end
      if option_2_name.blank?
        variation.update_attribute(:option_2, nil)
      end
      if option_3_name.blank?
        variation.update_attribute(:option_3, nil)
      end
    end
  end
  
  def active?
  	display? && !recycled?
  end
  
  def total_stock
    ret = 0
    for variation in variations
      ret += variation.stock
    end   
    ret
  end
  
  def image?
    image == nil ? false : true
  end
  
  def image
    if image_1?
      image_1
    elsif image_2?
      image_2
    elsif image_3?
      image_3
    elsif image_4?
      image_4
    else
      nil
    end    
  end
  
  def image_alt
    if image?
      self.send("#{image.name.to_s}_alt")
    else
      nil
    end
  end
  
  def option_1s
    variations.collect{|x| x.option_1}.uniq.sort
  end
  
  def option_1s_in_stock
    option_1s_in_stock = []
    for option_1 in option_1s
      if Variation.in_stock(self, option_1)
        option_1s_in_stock << option_1
      end
    end
    option_1s_in_stock
  end
  
  def option_1_options(selected)
    ret = ""
    ret += "<option value=''>#{option_1_name.pluralize}...</option>"
    for option_1 in option_1s
      if Variation.in_stock(self, option_1)
        if option_1 == selected
          ret += "<option selected='true'>#{option_1}</option>" 
        else 
          ret += "<option>#{option_1}</option>" 
        end        
      else
        ret += "<option disabled=\"true\">#{option_1} (out of stock)</option>" 
      end
    end
    ret
  end
  
  def option_2s
    variations.collect{|x| x.option_2}.uniq.sort
  end
  
  def option_2s_in_stock(option_1)
    option_2s_in_stock = []
    for option_2 in option_2s
      if Variation.in_stock(self, option_1, option_2)
        option_2s_in_stock << option_2
      end
    end
    option_2s_in_stock
  end
    
  def option_2_options(selected, option_1)
    ret = ""
    ret += "<option value=''>#{option_2_name.pluralize}...</option>"
    for option_2 in option_2s
      if Variation.in_stock(self, option_1, option_2)
        if option_2 == selected
          ret += "<option selected='true'>#{option_2}</option>" 
        else 
          ret += "<option>#{option_2}</option>" 
        end        
      else
        ret += "<option disabled=\"true\">#{option_2} (out of stock)</option>" 
      end
    end
    ret
  end  
    
  def option_3s
    variations.collect{|x| x.option_3}.uniq.sort
  end
  
  def option_3s_in_stock(option_1, option_2)
    option_3s_in_stock = []
    for option_3 in option_3s
      if Variation.in_stock(self, option_1, option_2, option_3)
        option_3s_in_stock << option_3
      end
    end
    option_3s_in_stock
  end
  
  def option_3_options(selected, option_1, option_2)
    ret = ""
    ret += "<option value=''>#{option_3_name.pluralize}...</option>"
    for option_3 in option_3s
      if Variation.in_stock(self, option_1, option_2, option_3)
        if option_3 == selected
          ret += "<option selected='true'>#{option_3}</option>" 
        else 
          ret += "<option>#{option_3}</option>" 
        end        
      else
        ret += "<option disabled=\"true\">#{option_3} (out of stock)</option>" 
      end
    end
    ret
  end
    
  def product_images
    images = []
    images << image_1 if image_1?
    images << image_2 if image_2?
    images << image_3 if image_3?
    images << image_4 if image_4?
    images
  end
  
  def youtube_video_code
    if youtube_link?
      scan = youtube_link.scan(/^.*v=(\w*)\W?$/)
      if scan.first && scan.first.first
        return scan.first.first
      end
    end
    return nil
  end  
  
end
