require 'nokogiri'
class SentimentAnalyzerDutch < SentimentLib::Analysis::Strategy
  
  def mappings
    data = {}
    text = File.open(Rails.root.join('data', 'nl', 'duopattern.txt')).read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      parts = line.split("\t")
      data[parts[0]] = parts[1].to_f
    end
    data
  end
  
  # def weigh(tokens)
#     
  # end
  
end