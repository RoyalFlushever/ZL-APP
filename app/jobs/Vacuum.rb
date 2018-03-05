module Vacuum
  class Request
    def run(asins)
      # result = nil
      # credentials = Redis.current.zrange("credentials", 0, -1)
      # until result || credentials.empty?
      #   key = credentials.pop
      #   result = begin
      #     self.configure(JSON.parse(key))
      #     Redis.current.zadd("credentials", Time.now.to_i, key)
      #     self.item_lookup(query: asins)
      #   rescue Excon::Error::ServiceUnavailable
      #     nil
      #   end
      # end
      # result || run(asins)
    end
  end
  extend self
end