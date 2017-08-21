class TrainerSerializer < BaseSerializer

  attributes :id, :created_at, :first_name, :last_name, :email, :mobile, :office, :phone, :abn, :birthdate, :gst, :publishable_key, :bank

  has_one :trainer_identification, key: :identification
  has_one :trainer_verification, key: :verification

  has_one :address
  has_one :profile_image, key: :image
  has_one :gym, serializer: GymShortSerializer
  has_one :gym_location
  has_one :targets

  cached

  def publishable_key
    object.stripe_detail.publishable_key rescue nil
  end

  def created_at
    object.created_at.to_i
  end

  def birthdate
    object.birthdate.strftime("%Y-%m-%d") rescue nil
  end

  def bank
    {last_4: object.bank_last_4}
  end

  self.version = 1.4

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end

end
