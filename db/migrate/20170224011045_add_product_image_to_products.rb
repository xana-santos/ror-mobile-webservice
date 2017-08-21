class AddProductImageToProducts < ActiveRecord::Migration
  def change
    # Commenting these files out purely for
    # remove_column :products, :product_image_file_name
    # remove_column :products, :product_image_content_type
    # remove_column :products, :product_image_file_size
    # remove_column :products, :product_image_updated_at
    add_column :products, :product_image, :string
  end
end
