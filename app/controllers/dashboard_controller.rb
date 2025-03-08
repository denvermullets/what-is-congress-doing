class DashboardController < ApplicationController
  def index
    render :index
  end

  def ingest_bills
    IngestBills.perform_later
  end

  def ingest_bill_text
    ProcessBillTexts.perform_later
  end

  def ingest_ai_text
    # bills = Bill.all
    # bills = Bill.last(10)
    # bills = Bill.sample
    # OllamaIngestBill.perform_later(bill: Bill.all.sample)
    Bill.all.limit(400).map { |bill| OllamaIngestBill.perform_later(bill:) }
    # bills.map { |bill| OllamaIngestBill.perform_later(bill:) }
  end
end
