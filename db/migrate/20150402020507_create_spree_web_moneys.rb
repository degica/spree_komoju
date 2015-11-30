class CreateSpreeWebMoneys < ActiveRecord::Migration
  def change
    create_table :spree_web_moneys do |t|
      t.integer :user_id
      t.integer :payment_method_id
      t.string  :brand, default: "web_money"
      t.string  :last_digits
      t.timestamps null: false
    end
    add_index :spree_web_moneys, :user_id
    add_index :spree_web_moneys, :payment_method_id
  end
end
