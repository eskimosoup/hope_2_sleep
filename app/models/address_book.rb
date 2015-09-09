# MODEL TO TRANSFER DATA FROM OLD WEBSITE

class AddressBook < ActiveRecord::Base

	def self.table_name()
	 "address_book"
	end
	
  belongs_to :customer, :foreign_key => "customers_id", :primary_key => "customers_id"
  belongs_to :country, :foreign_key => "entry_country_id", :primary_key => "countries_id"
  
end
