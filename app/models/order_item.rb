class OrderItem < ActiveRecord::Base
	
	acts_as_eskimagical
	
	belongs_to :order
	belongs_to :variation
  
	named_scope :position, :order => "position"
  named_scope :active, :conditions => ["recycled = ? AND display = ?", false, true]
  named_scope :recycled, :conditions => ["recycled = ?", true]
  named_scope :unrecycled, :conditions => ["recycled = ?", false]
  
  def active?
  	display? && !recycled?
  end
  
  def restore_stock
    if Variation.exists?(variation_id)
      variation.update_attribute(:stock, variation.stock + amount)
    end
  end
  
end
