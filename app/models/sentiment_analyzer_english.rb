require 'nokogiri'
class SentimentAnalyzerDutch < SentimentLib::Analysis::Strategy
  
  def mappings
    data = {}
    xml_doc  = File.open(Rails.root.join('data', 'en', 'sentiment.xml')) { |f| Nokogiri::XML(f) }
    xml_doc.xpath("//word").each do |word|
      data[word.attr('form')] = word.attr('polarity').to_f
    end
    data
  end
  
  # def weigh(tokens)
#     
  # end
  
end