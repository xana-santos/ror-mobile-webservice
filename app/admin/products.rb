ActiveAdmin.register Product do
  include SharedAdmin

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        super - ['edit', 'destroy', 'new']
      end
    end
  end

  
  permit_params :title, :description, :unit_price, :unit_type,
                :categories, :out_of_stock, :cost, :unit_price,
                :deleted_at, :api_token, :product_image


  menu priority: 5


  filter :id
  filter :api_token
  filter :title
  filter :description
  filter :product_categories, as: :check_boxes, collection: proc { ProductCategory.all.map{|c| [c.category, c.id]} }

  index do
    selectable_column
    id_column
    column :api_token
    column :title
    column :description
    column :unit_price
    column :unit_type
    column :categories do |p|
      p.product_categories.map{|c| c.category}.join(", ")
    end
    column :out_of_stock
    column :cost
    column :product_image do |p|
      image_tag(p.product_image.thumb.url) if p.product_image?
    end
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    attributes_table do
     row :id
     row :title
     row :description
     row :product_id
     row :unit_price
     row :unit_type
     row :categories do |p|
       p.product_categories.map{|c| c.category}.join(", ")
     end
     row :created_at
     row :updated_at
     row :status
     row :out_of_stock
     row :cost
     row :deleted_at
     row :api_token
     row :product_image do |p|
       image_tag(p.product_image.thumb.url) if p.product_image?
     end
   end
  end

  form do |f|
    f.inputs "Product", :multipart => true do
      f.input :title
      f.input :description
      f.input :unit_price
      f.input :unit_type
      f.input :categories
      f.input :out_of_stock
      f.input :cost
      f.input :unit_price
      f.input :deleted_at
      f.input :api_token
      f.input :product_image, :as => :file, :hint => f.object.product_image.present? \
        ? image_tag(f.object.product_image.thumb.url)
        : content_tag(:span, "no product image yet")
      f.input :product_image_cache, :as => :hidden
    end
    f.actions
  end
end
