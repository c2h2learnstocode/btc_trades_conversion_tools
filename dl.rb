require 'date'
#https://s3-eu-west-1.amazonaws.com/public.bitmex.com/data/trade/20141122.csv.gz
s_date=DateTime.new(2014,11,22)
e_date=Date.today


(s_date..e_date).each do |d|
    d_str= d.strftime("%Y%m%d")
    url = "https://s3-eu-west-1.amazonaws.com/public.bitmex.com/data/trade/#{d_str}.csv.gz"
    if !File.file?("#{d_str}.csv.gz")
      `wget -nv '#{url}'`
    end
end
