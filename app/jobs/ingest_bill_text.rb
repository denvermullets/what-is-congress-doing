# ingest the individual bill based on type

class IngestBillText < ApplicationJob
  def perform(bill)
    if bill.nil?
      puts 'something went wrong, bill is nil'
      return
    end

    @api_key = fetch_api_key
    @bill = bill

    fetch_url_data
  end

  def fetch_url_data
    text_links = fetch_data
    return unless text_links['textVersions'].present?

    sorted_data = text_links['textVersions'].sort_by do |item|
      date = item['date'] ? DateTime.parse(item['date']) : nil
      [date.nil? ? 1 : 0, date]
    end
    find_text = sorted_data.last['formats'].find { |element| element['type'] == 'Formatted Text' }
    @bill.update(text_url: find_text['url'])
    @bill.save

    puts "updated bill ##{@bill.id}"
  end

  private

  def fetch_data
    congress = @bill.congress
    type = @bill.bill_type.downcase
    number = @bill.number

    puts "finding bill #{congress}/#{type}/#{number}"
    url = "https://api.congress.gov/v3/bill/#{congress}/#{type}/#{number}/text?format=json"
    response = HTTParty.get(url, headers: { 'X-Api-Key' => @api_key })

    raise ApiRequestError, "API Request Failed: #{response.code} - #{response.message}" unless response.success?

    response.parsed_response
  end

  def log_and_raise(error)
    Rails.logger.error("Job failed: #{error.message}")
    raise error
  end

  def fetch_api_key
    api_key = ENV.fetch('CONGRESS_KEY', nil)
    raise MissingApiKeyError, 'CONGRESS_KEY is missing! Check your .env file.' if api_key.nil? || api_key.strip.empty?

    api_key
  end

  class MissingApiKeyError < StandardError; end
  class ApiRequestError < StandardError; end
end
