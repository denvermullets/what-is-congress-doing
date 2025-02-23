# a collection of api calls needed for jobs
module Congress
  class Api < Service
    def initialize
      @api_key = fetch_api_key
      @base = 'https://api.congress.gov/v3'
    end

    def fetch_bills(congress:, start:, end_date:, limit:)
      url = "#{@base}/bill/#{congress}?#{start}&#{end_date}&#{limit}&sort=updateDate asc"
      get_request(url)
    end

    def fetch_next_bills(url:)
      get_request(url)
    end

    def fetch_bill(congress:, type:, number:)
      url = "#{@base}/bill/#{congress}/#{type}/#{number}?format=json"
      get_request(url)
    end

    def fetch_member(member_id:)
      url = "#{@base}/member/#{member_id}?format=json"
      get_request(url)
    end

    def fetch_cosponsors(congress:, type:, number:)
      url = "#{@base}/bill/#{congress}/#{type.downcase}/#{number}/cosponsors?format=json&limit=250"
      get_request(url)
    end

    def fetch_bill_text(congress:, type:, number:)
      puts "finding bill #{congress}/#{type}/#{number}"
      url = "#{@base}/bill/#{congress}/#{type.downcase}/#{number}/text?format=json"
      get_request(url)
    end

    def fetch_text(url:)
      response = HTTParty.get(url)
      raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

      response.body.gsub(/\s+/, ' ').strip
    end

    private

    def get_request(url)
      response = HTTParty.get(url, headers: { 'X-Api-Key' => @api_key })
      raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

      response.parsed_response
    end

    def fetch_api_key
      api_key = ENV.fetch('CONGRESS_KEY', nil)
      raise MissingApiKeyError, 'CONGRESS_KEY is missing! Check your .env file.' if api_key.nil? || api_key.strip.empty?

      api_key
    end

    class MissingApiKeyError < StandardError; end
    class ApiRequestError < StandardError; end
  end
end
