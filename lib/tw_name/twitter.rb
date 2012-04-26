require 'rubygems'
require 'json'

module TwName
  class Twitter
    class << self

      RATE_LIMIT_EXCEED="Rate limit exceeded"
      def checktw name
        response=`curl -s https://twitter.com/users/show_for_profile.json?screen_name=#{name}`
        response=JSON.parse(response)

        if ( error=response['error'] )
          raise RATE_LIMIT_EXCEED if error =~ /Rate limit exceeded/
          return nil if error=="Not found"
          return "suspended" if error=="User has been suspended"
        end
  
        result = %w[friends followers statuses].collect{|t| m=response["user"]["#{t}_count"]}.join("=")
      end

      def checktw_safe name, &block
        tries=0
        while true
          begin
            return checktw(name)
            break
          rescue RuntimeError=>e
            if RATE_LIMIT_EXCEED==e.to_s
              # break # if you only want to check on cache
              yield(tries) if block
              sleep 600 
              tries+=1
            else
              raise e
            end
          end
        end
      end

    end
  end
end
    