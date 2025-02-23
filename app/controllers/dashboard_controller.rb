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
    # bill = Bill.where()
  end
end
