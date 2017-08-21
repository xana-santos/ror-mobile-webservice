ActiveAdmin.register Consultation do
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
  
  menu priority: 4
  
  index do
    selectable_column
    id_column
    column :api_token
    column :client
    column :trainer
    column :consultation_date
    column :consulted_at
    column :comments
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  filter :id
  filter :api_token
  filter :client, as: :select, collection: proc { Client.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }
  filter :trainer, as: :select, collection: proc { Trainer.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }
  filter :consultation_date
  
  show do
    
    attributes_table do
      ::Consultation.column_names.reject{|i| ["image_urls"].include? i}.sort.each do |name|
        row name.to_sym
      end
    end
    
    panel "Images", only: :show do
      
      columns do
      
        consultation.images.each do |i|
          
          column max_height: 400, max_width: 400 do
            span link_to((image_tag "https://#{Settings.amazon.app_bucket}.s3.amazonaws.com/#{i.url}", style: "max-width: 100%"), admin_image_path(i))
          end
                          
        end
        
      end
      
    end
    
    panel "Other Consultations" do
      
      
      consultation.client.consultations.where.not(id: consultation.id).in_groups_of(3, false).each do |prev_consultations|
      
        columns do
      
          prev_consultations.each do |prev_consultation|
        
            column do
        
                span do
          
                  attributes_table_for prev_consultation do
                    ::Consultation.column_names.reject{|i| ["image_urls"].include? i}.sort.each do |name|
                      row name.to_sym
                    end
                  end
          
                end
          
            end
        
          end
      
        end
      
      end
                  
    end
      
  end
  
end
