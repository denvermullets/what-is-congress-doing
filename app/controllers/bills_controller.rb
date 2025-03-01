class BillsController < ApplicationController
  include Pagy::Backend

  def index
    pagy, bills = pagy(Bill.all)
    render :index, locals: { bills:, pagy: }
  end
end
