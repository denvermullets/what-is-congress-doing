class IngestBills < ApplicationJob
  def perform
    api_key = fetch_api_key
    json_response = fetch_data(api_key)

    process_data(json_response)
  rescue StandardError => e
    log_and_raise(e)
  end

  private

  def fetch_api_key
    api_key = ENV.fetch('CONGRESS_KEY', nil)
    raise MissingApiKeyError, 'CONGRESS_KEY is missing! Check your .env file.' if api_key.nil? || api_key.strip.empty?

    api_key
  end

  def fetch_data(api_key)
    url = 'https://api.example.com/data'
    response = HTTParty.get(url, headers: { 'X-Api-Key' => api_key })

    raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

    response.parsed_response
  end

  def process_data(json_response)
    Rails.logger.info("Parsed Response: #{json_response}")
    return unless json_response.key?('data')

    puts "Data Field: #{json_response['data']}"
    # Example: Save data to DB if needed
    # SomeModel.create!(data: json_response['data'])
  end

  def log_and_raise(error)
    Rails.logger.error("Job failed: #{error.message}")
    raise error # Ensures retry behavior
  end

  class MissingApiKeyError < StandardError; end
  class ApiRequestError < StandardError; end
end
