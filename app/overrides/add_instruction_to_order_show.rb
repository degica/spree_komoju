Deface::Override.new(:virtual_path => 'spree/orders/show',
                     :name => 'add_instruction_to_order_show',
                     :insert_before => "fieldset#order_summary legend",
                     :text => "
<% if !@order.paid? && @order.payments.last.source.try(:instruction_partial_path) %>
  <%= render @order.payments.last.source.instruction_partial_path, source: @order.payments.last.source %>
<% end %>")
