class DashboardController < ApplicationController
  def index
    render :index
  end

  def ingest_bills
    IngestBills.perform_later
  end
end
