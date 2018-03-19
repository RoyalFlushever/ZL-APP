module Stripe
  class Event < APIResource
    extend Stripe::APIOperations::List

    OBJECT_NAME = "event".freeze
  end
end
