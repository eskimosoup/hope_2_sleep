# MODEL TO TRANSFER DATA FROM OLD WEBSITE

class Customer < ActiveRecord::Base

  has_many :address_books, :foreign_key => "customers_id", :primary_key => "customers_id"
  
  def self.convert_to_users
    for customer in Customer.all
      user = User.create!(:first_names => customer.customers_firstname, 
                      :surname => customer.customers_lastname, 
                      :email => customer.customers_email_address,
                      :password => "password",
                      :password_confirmation => "password")
      NewsletterSubscriber.create!(:email => customer.customers_email_address) if customer.customers_newsletter?
      for address_book in customer.address_books
        address = Address.new(:user_id => user.id,
                       :surname => address_book.entry_firstname,
                       :first_names => address_book.entry_lastname,
                       :address_1 => address_book.entry_street_address,
                       :address_2 => address_book.entry_street_address_2,
                       :city => address_book.entry_city,
                       :postcode => address_book.entry_postcode)
        address.country = address_book.country.countries_iso_code_2
        address.save
      end
    end
  end
  
end
