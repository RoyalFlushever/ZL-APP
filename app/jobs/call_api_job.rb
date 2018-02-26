class CallApiJob < ActiveJob::Base 

  queue_as :default

  def perform(filename)
  	@progress_bar = Progressbar.find_by(taskname: filename)
    11.times do |i|
    	sleep(1)
      @progress_bar.update_attributes!(percent: i * 10)
    end
    
  end

end
	