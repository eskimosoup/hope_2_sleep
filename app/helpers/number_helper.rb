module NumberHelper

  def number_to_pounds(number)
	  number_to_currency(number, :unit => "&pound;")
	end

end
