class ClientSerializer < BaseSerializer

  attributes :id, :created_at, :first_name, :last_name, :email, :birthdate, :mobile, :mobile_preferred, :office, :phone, :active

  has_one :client_card, key: :card
  has_one :client_detail, key: :client_details
  has_many :addresses
  has_one :trainer, serializer: TrainerShortSerializer
  has_one :image

  def created_at
    object.created_at.to_i
  end

  self.version = 1.2

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end

end
