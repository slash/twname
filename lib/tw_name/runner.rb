require 'tw_name/cache'
require 'tw_name/twitter'
require 'tw_name/name_generator'

module TwName
  class Runner
    def self.run(name = nil, min_chars = 1, max_chars = -1, *beloweds)
      min_chars=min_chars.to_i
      max_chars=max_chars.to_i
      max_chars=name.to_s.length if max_chars==-1
      
      exit 1 unless check_args(name, min_chars, max_chars, beloweds)
      
      cache=TwName::Cache.new

      print "pregenerating names ... "
      allnames=TwName::NameGenerator.new(name, min_chars, max_chars, beloweds).allnames
      puts "#{allnames.length} to be checked"
      
      allnames.each do |tw| 
        print tw," "
        puts "\nwoohoo "+tw if cache.recache(tw) do 
          TwName::Twitter.checktw_safe(tw){puts "\n"+"Twitter Rate limit exceeded - sleeping 600"}
          sleep rand*2 # regular sleep between each twitter name check
        end
      end

    end    

    def self.check_args name, min_chars, max_chars, beloweds
      valid = !name.to_s.empty? && min_chars > 0 && max_chars > 0 && min_chars<=max_chars && max_chars <= name.length
      warning = beloweds.empty?
      usage = File.read("README")

      puts "Error!\n  one of the following rules is broken" unless valid
      puts "Warning!\n  you should consider adding a few names you like, so that results are sorted around them" if warning
      puts usage if !valid || warning

      valid
    end

  end
  
end
