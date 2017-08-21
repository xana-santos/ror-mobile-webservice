class RenameWrongResetTableName < ActiveRecord::Migration
  def change
    rename_column :users, :resent_sent, :reset_sent
  end
end
