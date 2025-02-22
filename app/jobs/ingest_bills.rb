class IngestBills < ApplicationJob
  def perform
    api = Congress::Api.new
    json_response = api.fetch_bills(
      congress: 119, start: 'fromDateTime=2025-01-19T00:00:00Z',
      end_date: 'toDateTime=2025-02-14T00:00:00Z', limit: 'limit=20'
    )

    process_data(json_response)
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
        # TODO: bill exists, check if latest action is the same
      end
    end
  end
end
