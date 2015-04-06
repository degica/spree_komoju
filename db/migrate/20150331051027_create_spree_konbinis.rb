class CreateSpreeKonbinis < ActiveRecord::Migration
  def change
    create_table :spree_konbinis do |t|
      t.string  :convenience
      t.integer :user_id
      t.integer :payment_method_id
      t.string  :brand, default: "konbini"
      t.string  :receipt
      t.string  :confirmation_code
      t.string  :instructions_url
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_index :spree_konbinis, :user_id
    add_index :spree_konbinis, :payment_method_id
  end
end
