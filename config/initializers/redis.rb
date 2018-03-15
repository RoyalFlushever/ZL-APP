begin
	Redis.current = Redis.new(url: ENV["REDIS_URL"])
rescue Exception => e
  puts e
end

Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_1'])
Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_2'])
Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_3'])