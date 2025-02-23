# first we get the intial set of bills and then follow pagination by subsequent queues

class IngestBills < ApplicationJob
  def perform(url: nil)
    api = Congress::Api.new

    json_response = if url.nil?
                      api.fetch_bills(
                        congress: 119, start: 'fromDateTime=2025-01-19T00:00:00Z',
                        end_date: 'toDateTime=2025-02-24T00:00:00Z', limit: 'limit=100'
                      )
                    else
                      api.fetch_next_bills(url:)
                    end

    if json_response['pagination'].present? && json_response['pagination']['next'].present?
      IngestBills.perform_later(url: json_response['pagination']['next'])
      puts "queues up next: #{json_response['pagination']['next']}"
    end

    process_data(json_response)
    puts 'executing cooldown on overall bills'
    sleep(3)
    puts 'resuming api calls'
  end

  private

  def process_data(json_response)
    return unless json_response.key?('bills')

    json_response['bills'].each do |bill|
      existing_bill = Bill.where(congress: bill['congress'], number: bill['number'])
      if existing_bill.empty?
        # kick off individual bill ingest
        IngestBill.perform_later(bill)
      else
        puts 'bill previously exists'
        # TODO: bill exists, check if latest action is the same
      end
    end
  end
end
