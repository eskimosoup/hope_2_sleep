class User < ActiveRecord::Base
	
  acts_as_eskimagical
	acts_as_authentic
	
	validates_presence_of :first_names, :surname
	
	has_many :orders
	has_many :addresses
	has_many :reviews
	
	named_scope :position, :order => "position"
  named_scope :active, :conditions => ["recycled = ? AND display = ?", false, true]
  named_scope :recycled, :conditions => ["recycled = ?", true]
  named_scope :unrecycled, :conditions => ["recycled = ?", false]
  
  def active?
  	display? && !recycled?
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    UserMailer.deliver_password_reset_instructions(self)  
  end  
  
  def name
    "#{first_names} #{surname}"
  end
  
end
