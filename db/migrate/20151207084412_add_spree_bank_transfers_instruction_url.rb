class AddSpreeBankTransfersInstructionUrl < ActiveRecord::Migration
  def change
    add_column :spree_bank_transfers, :instructions_url, :string
  end
end
