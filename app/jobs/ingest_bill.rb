# ingest the individual bill based on type

class IngestBill < ApplicationJob
  def perform(bill)
    api = Congress::Api.new
    json_response = api.fetch_bill(
      congress: bill['congress'], type: bill['type'].downcase, number: bill['number']
    )

    new_bill = Congress::IngestBillData.call(bill:, json_response:)

    puts "kicking off new bill #{new_bill.id}"
    IngestBillText.perform_later(new_bill)
  end
end
