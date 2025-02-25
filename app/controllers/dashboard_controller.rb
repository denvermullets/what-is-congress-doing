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
    bills = Bill.where.not(text_url: nil).last(200)
    bills.map { |bill| OllamaIngestBill.perform_later(bill:) }
  end
end
