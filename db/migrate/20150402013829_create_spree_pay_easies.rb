class CreateSpreePayEasies < ActiveRecord::Migration
  def change
    create_table :spree_pay_easies do |t|
      t.string  :email
      t.string  :phone
      t.string  :given_name
      t.string  :family_name
      t.string  :given_name_kana
      t.string  :family_name_kana
      t.integer :user_id
      t.integer :payment_method_id
      t.string  :brand, default: "pay_easy"
      t.string  :pay_url
      t.string  :instructions_url
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_index :spree_pay_easies, :user_id
    add_index :spree_pay_easies, :payment_method_id
  end
end
