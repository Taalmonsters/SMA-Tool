require 'nokogiri'
class SentimentAnalyzerEnglish < SentimentLib::Analysis::Strategy
  
  def mappings
    data = {}
    data = data.merge(load_positive_words)
    data = data.merge(load_negative_words)
    data = data.merge(load_pattern_data)
    data = data.merge(load_mpqa_data)
    data
  end
  
  def load_mpqa_data
    data = {}
    text = File.open(Rails.root.join('data', 'en', 'lexicon2.txt')).read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      parts = line.split(" ")
      pol = 0.0
      if parts[5].eql?('priorpolarity=negative')
        if parts[0].include?('weak')
          pol = -0.3
        else
          pol = -0.75
        end
      elsif parts[5].eql?('priorpolarity=positive')
        if parts[0].include?('weak')
          pol = 0.3
        else
          pol = 0.75
        end
      end
      data[parts[2].gsub(/word1\=/,'')] = pol
    end
    data
  end
  
  def load_positive_words
    load_words(Rails.root.join('data', 'en', 'positive.txt'), 0.75)
  end
  
  def load_negative_words
    load_words(Rails.root.join('data', 'en', 'negative.txt'), -0.75)
  end
  
  def load_words(file, polarity)
    data = {}
    text = File.open(file).read
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      data[line] = polarity
    end
    data
  end
  
  def load_pattern_data
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