Deface::Override.new(:virtual_path => 'spree/orders/show',
                       :name => 'add_instruction_to_order_show',
                       :insert_before => "fieldset#order_summary legend",
                       :text => "
<% if @order.paid? == false %>
<div class='alert alert-info' role='alert'>
<%= @order.payments.last.source.instruction %>
</div>
<% end %>")
