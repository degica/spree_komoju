class CreateSpreeWebMoneys < ActiveRecord::Migration
  def change
    create_table :spree_web_moneys do |t|
      t.string :email
      t.string :payment_uuid
      t.integer :short_amount
      t.text :prepaid_cards
      t.integer :user_id
      t.integer :payment_method_id
      t.string :brand, default: "web_moneys"

      t.timestamps null: false
    end
    add_index :spree_web_moneys, :user_id
    add_index :spree_web_moneys, :payment_method_id
  end
end
