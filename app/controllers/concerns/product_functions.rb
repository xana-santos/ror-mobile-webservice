module ProductFunctions
  extend ActiveSupport::Concern

  private

  def set_product_attributes(p)
    # p["images_attributes"] = p.delete("images") if p["images"]
  end

  def set_update_product_attributes(p, product)

    # if p["images"]
    #   p["images_attributes"] = p.delete("images")
    #   product.images.each{|a| p["images_attributes"] << {"id" => a.id, "_destroy" => true} }
    # end

  end

  def check_product_attributes(params)
    show_errors({product_id: "already exists in the system. Please try another."}) or return unless Product.find_by(product_id: params["product_id"]).blank?
    return true
  end

end
