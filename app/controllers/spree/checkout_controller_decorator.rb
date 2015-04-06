Spree::CheckoutController.class_eval do
  def permitted_source_attributes
    super.push(permitted_komoju_konbini_attributes)
  end

  private

  def permitted_komoju_konbini_attributes
    :convenience
  end
end

