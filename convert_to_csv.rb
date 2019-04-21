require 'zlib'
require 'csv'

files= Dir["../20*.gz"].sort { |a,b| a <=> b}

puts "Date,Open,High,Low,Close,Volume"

class Dailytrade
  attr_accessor :open, :high, :low, :close, :volume

  def initialize
    @low=100000
		@high=-1
		@date = nil
    @open=nil
		@close=nil
		@volume = 0
		@gross_value_total=0
	end

	def add_trade arr
	  #sample: timestamp,symbol,side,size,price,tickDirection,trdMatchID,grossValue,homeNotional,foreignNotional
    #sample: ["2018-12-23D07:09:37.549856000", "XBTUSD", "Sell", "422", "3978.5", "MinusTick", "a1d3dfe7-da2c-f1d0-40da-a5c551c08a56", "10606970", "0.1060697", "422"]
		price = arr[4].to_f
	  @date = arr[0]	
		if @open.nil?
		  @open = price
		end

		@close = price
		
		if price>@high
			@high = price
		end

		if price<@low
		  @low = price
		end

		@volume = @volume + arr[9].to_i
		@gross_value_total = @gross_value_total  + arr[7].to_i

	end

  def get_line
    "#{@date},#{@open},#{@high},#{@low},#{@close},#{@volume}"
	end

end


files.each do |f|
	day=Dailytrade.new
  Zlib::GzipReader.open(f) do |gzip|
    csv = CSV.new(gzip)
    csv.each do |row|
      if row[1]=="XBTUSD"
							day.add_trade row 

      end	
    end
	end
	puts day.get_line
end

