class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        :full_name,
        :document_id,
        :phone_number,
        :address_street,
        :address_number,
        :address_complement,
        :address_neighborhood,
        :address_city,
        :address_state,
        :address_zip_code,
        :address_country
      ]
    )
  end
end
