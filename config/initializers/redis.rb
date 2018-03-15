begin
	Redis.current = Redis.new(:host => ENV["REDIS_HOST"], :port => ENV["REDIS_PORT"])
rescue Exception => e
  puts e
end
Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_2'])
Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_1'])
Redis.current.zadd("credentials", Time.now.to_i, ENV['AMAZON_KEY_3'])