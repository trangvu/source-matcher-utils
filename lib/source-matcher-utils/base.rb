require 'csv'
require 'rest_client'
require 'ferret'
include Ferret

# Base class
class SourceMatcherUtils
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def search_career_site(query)
    link = ""
    begin
      res = RestClient.get 'https://www.googleapis.com/customsearch/v1', {:params => 
        {:key => 'AIzaSyCHV9bNmv8zSpyOmHLjVhf4tDKrah7VGn4', :cx => '002224812850298357850:4u-8yarxsey', 
          :num => 1, :q => "#{query} jobs"}}
      result = JSON.parse(res)
      link = result['items'][0]["link"].to_s
    rescue => error
      puts "Error while searching for career site #{error}"
    end
    link
  end

  def index_from_csv(index, file, col, index_type)
    puts "Start index #{index_type}"
    cnt = 0

    CSV.foreach(file, headers: true) do |row|
      # puts row.inspect # hash
      data = row.to_hash
      index << {:type => "index_type", :content => data[data.keys[col]].to_s.force_encoding("UTF-8")}
      cnt += 1
    end
    puts "Complete index #{cnt} #{index_type} names"
    index
  end

  def matching
    puts "Match #{options}"
    # Index crawler
    
    crawler_index = index_from_csv(Index::Index.new(), options['crawler'], options['crawler-col'].to_i, 'crawler')
    source_index = index_from_csv(Index::Index.new(), options['source'], options['source-col'].to_i, 'source')

    puts "Calculate word frequency"
    wf = {}
    queries = []
    CSV.foreach(options['external'], headers: true) do |row|
      # puts row.inspect # hash
      data = row.to_hash
      col_name = data.keys[options['external-col'].to_i]
      if !data['advertiser'].nil?
        data['advertiser'].downcase.split(' ').each{ |term|
          wf[term] = wf.key?(term) ? wf[term] + 1 : 1 
        }
        queries << data['advertiser']
      end
    end

    puts "Start matching against crawler name"
    cnt = 0
    CSV.open("matched_output.csv", "w") do |csv|
        csv << ["Name", "Significant word", "Crawler significant word matched?", "Crawler Match#1", "Crawler Match#2", "Crawler Match#3", "Source significant word matched", "Source Match#1", "Source Match#2", "Source Match#3", "Link"]
        queries.each {|query|
          row = {}
          freq = {}
          query.downcase.split(' ').each{|term|
            freq[term] = wf[term]
          }
          row[:sigterm] = freq.key(freq.values.min)
          row[:name] = query
          row[:cmatched] = false
          # puts "Search for #{query}"
          # puts "Significant term #{row[:sigterm]}"
          idx = 0
          crawler_index.search_each("type:('crawler') content:('#{query}')") {|id, score|
            if score > 0.5 
              idx += 1
              row["match#{idx}"] = crawler_index[id][:content]
              matched = crawler_index[id][:content].downcase.include?(row[:sigterm]) rescue false
              row[:cmatched] = row[:cmatched] || matched          
              break if idx >= 3
            else
              break
            end
          }      

          idx = 0
          row[:smatched] = false
          source_index.search_each("type:('source') content:('#{query}')") {|id, score|
            if score > 0.8 
              idx += 1
              row["smatch#{idx}"] = source_index[id][:content]
              matched = source_index[id][:content].downcase.include?(row[:sigterm]) rescue false
              row[:smatched] = row[:smatched] || matched          
              break if idx >= 3
            else
              break
            end
          }

          # row["link"] = search_career_site(query)

          begin
            csv << [row[:name], row[:sigterm], row[:cmatched], row["match1"], row["match2"], row["match3"], row[:smatched], row["smatch1"], row["smatch2"], row["smatch3"], row["link"]]
            cnt += 1
          rescue => error
            puts "Error while write for query [#{query}] to csv with error #{error}"
          end
        }    
    end   
    puts "Complete match #{cnt} external sources"    
  end  
end
