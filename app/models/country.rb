# MODEL TO TRANSFER DATA FROM OLD WEBSITE

class Country < ActiveRecord::Base

  has_many :address_books, :foreign_key => "contries_id", :primary_key => "contries_id"
  
end
