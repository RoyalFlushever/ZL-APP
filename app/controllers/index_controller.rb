class IndexController < ApplicationController
	def index
		p "Redis Connected" + Redis.current.zrevrange("credentials", 0, -1).to_s
	end

	def create
		filename = params[:filename]
		CallApiJob.perform_later(filename)
	end
end
