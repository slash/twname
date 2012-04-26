module TwName
  class Cache
    def initialize
      @filecache={}
    end

    def recache name
      cached(name) ? checkcache(name) : cachename(name, yield())
    end

    def cached name
      !checkcache(name).nil?
    end

  private

    @filecache={}
    FNAME="#{File.dirname(__FILE__)}/../../cache/twnames"

    def loadcache
      `touch #{FNAME}`
      @filecache.clear
      File.readlines(FNAME).each do |l|
        name,available=l.split("=")
        @filecache[name]=available.chomp==true.to_s
      end
      nil
    end

    def cacheloaded?
      !@filecache.empty?
    end

    def cachename name, followers
      available=followers.nil?
      @filecache[name]=available
  
      File.write(FNAME,[name,available,followers.to_s].join("=")+"\n", File.size(FNAME))
      available
    end

    def checkcache name
      loadcache unless cacheloaded?
      @filecache[name]
    end

  end
end