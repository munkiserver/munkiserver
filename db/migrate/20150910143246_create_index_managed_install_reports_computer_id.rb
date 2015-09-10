class CreateIndexManagedInstallReportsComputerId < ActiveRecord::Migration
  def up
    add_index :managed_install_reports, :computer_id
  end

  def down
    remove_index :managed_install_reports, :computer_id
  end
end
