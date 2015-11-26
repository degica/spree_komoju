class AddGatewayProfileIdsToSpreeKonbinis < ActiveRecord::Migration
  def change
    add_column :spree_konbinis, :gateway_customer_profile_id, :string
    add_column :spree_konbinis, :gateway_payment_profile_id, :string
  end
end
