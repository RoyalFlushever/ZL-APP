class ChargesController < ApplicationController
  
  before_action :amount_to_be_charged
	before_action :set_description

  def new
    @filename = params[:filename]
    @amount = Progressbar.where(taskname: @filename).first.profit
    @total = Progressbar.where(taskname: @filename).first.total
  end

  def create
    @filename = params[:filename]
    @amount   = Progressbar.where(taskname: @filename).first.profit
  	customer = StripeTool.create_customer(
        email: params[:stripeEmail],
        stripe_token: params[:stripeToken])

    charge = StripeTool.create_charge(
      customer_id: customer.id,
      amount: (@amount * 100).to_i,
      description: @description)

    redirect_to result_show_path(filename: @filename)

  rescue Stripe::CardError => e
    puts 'error message'
    puts e.message
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  private
    def amount_to_be_charged

    end

    def set_description
      @description = "Zen Liquidator - app"
    end
end
