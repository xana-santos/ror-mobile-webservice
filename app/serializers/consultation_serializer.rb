class ConsultationSerializer < BaseSerializer
  attributes :id, :chest, :hips, :weight, :waist, :lean_body_weight, :body_fat_weight, :measurement, :left_arm, :right_arm, :glutes, :left_quads, :right_quads, :right_calf, :left_calf, :total_measurement, :fat_percentage, :comments, :consultation_date, :consultation_time
  has_many :images
  has_one :client, serializer: ClientShortSerializer
  has_one :trainer, serializer: TrainerShortSerializer
  
  def consultation_date
    object.consultation_date.strftime("%Y-%m-%d") rescue nil
  end
  
  cached
  
  self.version = 1.2
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
