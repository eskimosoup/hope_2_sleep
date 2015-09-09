class Variation < ActiveRecord::Base

  has_many :basket_items, :dependent => :destroy
	
	acts_as_eskimagical
	
	belongs_to :product
	
	validates_numericality_of :stock, :only_integer => true, :greater_than_or_equal_to => 0
	validates_presence_of :option_1, :if => Proc.new{|x| x.product.option_1_name? }
	validates_presence_of :option_2, :if => Proc.new{|x| x.product.option_2_name? }
	validates_presence_of :option_3, :if => Proc.new{|x| x.product.option_3_name? }
	validates_uniqueness_of :option_1, :scope => [:product_id, :option_2, :option_3], :message => " error: similar variation already exists"
	validates_uniqueness_of :option_2, :scope => [:product_id, :option_1, :option_3], :message => " error: similar variation already exists"
	validates_uniqueness_of :option_3, :scope => [:product_id, :option_1, :option_2], :message => " error: similar variation already exists"
	  
	named_scope :position, :order => "position"
  named_scope :active, :conditions => ["recycled = ? AND display = ?", false, true]
  named_scope :recycled, :conditions => ["recycled = ?", true]
  named_scope :unrecycled, :conditions => ["recycled = ?", false]
  named_scope :smart_order, :order => "option_1 ASC, option_2 ASC, option_3 ASC"
  
  def active?
  	display? && !recycled?
  end
  
  def self.in_stock(product, option_1=nil, option_2=nil, option_3=nil)
    variations = Variation.active
    variations = variations.option_1_equals(option_1) if option_1
    variations = variations.option_2_equals(option_2) if option_2
    variations = variations.option_3_equals(option_3) if option_3
    variations.find(:all, :conditions => ["stock > ? AND product_id = ?", 0, product.id]).length > 0 ? true : false
  end
  
  def product_name_variation
    ret = "#{product.name}"  
    ret += " (#{option_1})" if option_1?
    ret += " (#{option_2})" if option_2?
    ret += " (#{option_3})" if option_3?
    ret
  end
    
  # each model should have a name method, if name is not in the db and a summary method, if summary is not in the db
  # this is used for searching the models
  
  # if you want to tweak the searching for a model define search_string_1, search_string_2 and search_string_3
  # these default to name, summary and attributes, higher number, higher in the search
  
  
end
