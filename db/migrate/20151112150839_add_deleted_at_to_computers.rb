class AddDeletedAtToComputers < ActiveRecord::Migration
  def change
    add_column :computers, :deleted_at, :datetime
  end
end
