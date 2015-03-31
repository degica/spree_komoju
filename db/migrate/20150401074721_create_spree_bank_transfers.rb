class CreateSpreeBankTransfers < ActiveRecord::Migration
  def change
    create_table :spree_bank_transfers do |t|
      t.string  :email
      t.string  :phone
      t.string  :given_name
      t.string  :family_name
      t.string  :given_name_kana
      t.string  :family_name_kana
      t.integer :user_id
      t.integer :payment_method_id
      t.string  :brand, default: "bank_transfers"
      t.string  :order_id
      t.string  :bank_number
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_index :spree_bank_transfers, :user_id
    add_index :spree_bank_transfers, :payment_method_id
  end
end
