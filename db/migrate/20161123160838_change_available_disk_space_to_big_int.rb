class ChangeAvailableDiskSpaceToBigInt < ActiveRecord::Migration
  def change
    change_column :managed_install_reports, :available_disk_space, :bigint
  end
end
