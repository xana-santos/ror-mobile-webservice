class PurchasesController < ApplicationController
  include PurchaseFunctions
  before_filter :get_purchase
  
  def show
    @client = @purchase.client
    
    unless @client.terms_accepted
      set_return_to
      redirect_to client_terms_path(@client), alert: "You must accept these terms and conditions before you can confirm this purchase."
    end
    
  end
  
  def confirm
    @purchase.confirm!
    redirect_to purchase_path(@purchase), notice: "Purchase has successfully been confirmed"
  end
  
  def reject
    @purchase.reject!
    redirect_to purchase_path(@purchase), notice: "Purchase has successfully been rejected"
  end
  
  private
  
  def get_purchase
    @purchase = ::Purchase.find_by(api_token: (params[:purchase_id] || params[:id]))
    render_404 if @purchase.blank?
  end
  
end
