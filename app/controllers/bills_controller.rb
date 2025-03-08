class BillsController < ApplicationController
  include Pagy::Backend

  def index
    # pagy, bills = pagy(Bill.all)
    pagy, bills = pagy(Bill.where(rating: nil))
    render :index, locals: { bills:, pagy: }
  end

  def show
    bill = Bill.find(params[:id])

    render :show, locals: { bill: }
  end

  def update
    bill = Bill.find(params[:id])

    if update_bill(bill)
      flash.now[:type] = 'success'
      message = 'Updated stored JSON.'
    else
      flash.now[:type] = 'error'
      message = 'Something went wrong.'
    end

    render turbo_stream: turbo_stream.append('toasts', partial: 'shared/toast', locals: { message: })
  end

  private

  def update_bill(bill)
    ai_json = bill_params[:ai_json].presence&.then { |json| JSON.parse(json) } || {}
    bill.update(rating: bill_params[:rating]) && bill.bill_text.update(ai_json:)
  end

  def bill_params
    params.require(:bill).permit(:rating, :ai_json)
  end
end
