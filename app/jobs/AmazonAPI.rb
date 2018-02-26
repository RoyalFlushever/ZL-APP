class AmazonAPI
 # Your Access Key ID, as taken from the Your Account page
    ACCESS_KEY_ID = "AKIAIF26BH2GPD4XUI4A"

    # Your Secret Key corresponding to the above ID, as taken from the Your Account page
    SECRET_KEY = "uVru9q+UuZyEdu5fk/ZXBUDq7dwiP2fFV9wcxRpd"

    # The region you are interested in
    ENDPOINT = "webservices.amazon.com"

    REQUEST_URI = "/onca/xml"

  KEYS = {
    "AWS_ACCESS_KEY" => "AKIAIF26BH2GPD4XUI4A",
    "AWS_ASSOCIATES_TAG" => "rajavarman002-20",
    "AWS_SECRET_KEY" => "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"
  }

  # specific query methonds will go here
  # 
  # def generate_request_url params
  #   # Set current timestamp if not set
  #   params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")

  #   # Generate the canonical query
  #   canonical_query_string = params.sort.collect do |key, value|
  #     [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
  #   end.join('&')

  #   # Generate the string to be signed
  #   string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

  #   # Generate the signature required by the Product Advertising API
  #   signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), KEYS["AWS_SECRET_KEY"], string_to_sign)).strip()

  #   # Generate the signed URL
  #   request_url = "http://#{ENDPOINT}/#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  # end

  # def by_isbn isbn
  #   params = {
  #     "Service" => "AWSECommerceService",
  #     "Operation" => "ItemLookup",
  #     "AWSAccessKeyId" => KEYS["AWS_ACCESS_KEY"], 
  #     "AssociateTag" => KEYS["AWS_ASSOCIATES_TAG"], 
  #     "ItemId" => isbn,
  #     "IdType" => "ISBN",
  #     "ResponseGroup" => "ItemAttributes",
  #     "SearchIndex" => "All"
  #   }
  #   generate_request_url(params)
  #   # http://webservices.amazon.com/onca/xml?AWSAccessKeyId=AKIAIF26BH2GPD4XUI4A&AssociateTag=rajavarman002-20&IdType=ISBN&ItemId=158648642X&Operation=ItemLookup&ResponseGroup=ItemAttributes&SearchIndex=All&Service=AWSECommerceService&Timestamp=2018-02-26T19%3A10%3A48Z&Signature=SjS7KLpehuyV9uMx8a7Mvd%2FgCJYc1oP5KiLXv2eL9yc%3D
  #   # http://webservices.amazon.com/onca/xml?AWSAccessKeyId=AKIAIF26BH2GPD4XUI4A&AssociateTag=rajavarman002-20&IdType=ISBN&ItemId=B00HYE26HA&Operation=ItemLookup&ResponseGroup=ItemAttributes&SearchIndex=All&Service=AWSECommerceService&Timestamp=2018-02-26T19%3A02%3A19.000Z&Signature=fg3MjsybRVECf88yRkekaFlQFg4JG5TR1gixwe45PjE%3D
  #   # http://webservices.amazon.com/onca/xml?AWSAccessKeyId=AKIAIF26BH2GPD4XUI4A&AssociateTag=rajavarman002-20&IdType=ISBN&ItemId=&Operation=ItemLookup&ResponseGroup=ItemAttributes&SearchIndex=All&Service=AWSECommerceService&Timestamp=2018-02-26T19%3A00%3A39Z&Signature=QmNgmeWjuEra6183BMoqPQbWBkjns66a7MgxtCH0kZ0%3D
  # end

  def geturl isbn

   
    params = {
      "Service" => "AWSECommerceService",
      "Operation" => "ItemLookup",
      "AWSAccessKeyId" => "AKIAIF26BH2GPD4XUI4A",
      "AssociateTag" => "rajavarman002-20",
      "ItemId" => isbn,
      "IdType" => "ISBN",
      "ResponseGroup" => "ItemAttributes",
      "SearchIndex" => "All"
    }

    # Set current timestamp if not set
    params["Timestamp"] = Time.now.gmtime.iso8601 if !params.key?("Timestamp")

    # Generate the canonical query
    canonical_query_string = params.sort.collect do |key, value|
      [URI.escape(key.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join('=')
    end.join('&')

    # Generate the string to be signed
    string_to_sign = "GET\n#{ENDPOINT}\n#{REQUEST_URI}\n#{canonical_query_string}"

    # Generate the signature required by the Product Advertising API
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SECRET_KEY, string_to_sign)).strip()

    # Generate the signed URL
    request_url = "http://#{ENDPOINT}#{REQUEST_URI}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"

  end
end
