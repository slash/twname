module TwName
  class NameGenerator
    def initialize(name, min_chars, max_chars, beloweds=nil)
      @name=name
      @min_chars=min_chars
      @max_chars=max_chars
      @beloweds=beloweds
    end
    
    def weight_beloweds tw_name
      # the more belowed chars it contains - the better. Posittion doesn't matter right now.
      @beloweds.to_a.inject(0){|r,b| [r, weight_belowed(tw_name, b) + 3.0/tw_name.length].max} # the smalle - the better
    end

    def weight_belowed tw_name, belowed
      # indexed inject
      "#{belowed}_".chars.inject([0,1]) do |r_i,c|
        r,i=r_i
        ci=tw_name.index(c) # char index
        wi = !ci.nil?&&c=='_' ? (ci+1)*3 : i 
        # the '_' should always be counted as a 0.5 weight of normal unit in the place it stands in the char. 
        # so 
        #   tw_name=>'y_l',while belowed=>'yl'   is better than    tw_name=>'yl_',
        w=(ci.nil? ? 0 : 1.0/wi/(ci+1))
        # {prev weight}  +  { {1/i - further the belowed char - smaller the weight} / {divided by - further the char in tw_name} }
        # next index

        [r + w, i+1] 
      end.first
    end

    def allnames
      cache={}
      max=2 ** (@name.length)
      n=0
      while(n<max) do
        tw=""
        @name.chars.each_with_index{|c,i| tw << c if (n & (2 ** i))!=0}
        cache[tw]=true
        n+=1
      end

      # filter lengths by between - and sort by weight
      nchar = cache.keys\
        .reject{|s| !s.length.between?(@min_chars, @max_chars)}\
        .sort{|a,b| weight_beloweds(b) <=> weight_beloweds(a)}
    end

  end
end