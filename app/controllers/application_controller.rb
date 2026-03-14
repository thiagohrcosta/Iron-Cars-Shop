class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    link_count = link_lead_negotiations_for(resource)
    if link_count.positive?
      flash[:notice] = [ flash[:notice], "#{link_count} conversation#{'s' if link_count != 1} linked to your account." ].compact.join(" ")
    end

    return admin_dashboard_path if resource.respond_to?(:admin?) && resource.admin?

    user_dashboard_path
  end

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

  def link_lead_negotiations_for(resource)
    return 0 unless resource.is_a?(User)

    LeadNegotiationLinker.new(user: resource).call
  end
end
