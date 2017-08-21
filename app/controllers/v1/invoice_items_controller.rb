class V1::InvoiceItemsController < ApiController
  include InvoiceFunctions
  
  def show
    
    invoice_item = ::InvoiceItem.fetch_by_api_token(params["id"])
    
    check_exists invoice_item or return
    
    render json: invoice_item, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    invoice_items = ::InvoiceItem.by_record(params["record_type"], params["record_id"])
    
    filtered = invoice_items.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "invoice_items", meta: metadata, status: 200 and return
        
  end
  
end
