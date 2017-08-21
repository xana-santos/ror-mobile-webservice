class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :referee_id, index: true, foreign_key: true
      t.integer :referrer_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
