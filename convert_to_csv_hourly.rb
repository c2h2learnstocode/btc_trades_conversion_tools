require 'zlib'
require 'csv'
require 'time'

files= Dir["../20*.gz"].sort { |a,b| a <=> b}

puts "Date,Open,High,Low,Close,Volume"

class Unittrade
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

class Hourly
  def initialize
    @time=nil
  end

  def add_trade arr
    new_time = Time.parse(arr[0])
    if @time.nil?  #brand new
       @unittrade = Unittrade.new
       @time= new_time
    end

    if new_time.hour != @time.hour #new hour 
       puts @unittrade.get_line
       @unittrade = Unittrade.new
       @time= new_time
    end
    
    @unittrade.add_trade arr
  end

end


files.each do |f|
  hourly=Hourly.new
  Zlib::GzipReader.open(f) do |gzip|
    csv = CSV.new(gzip)
    csv.each do |row|
      if row[1]=="XBTUSD"
	hourly.add_trade row 
      end	
    end
  end
end

