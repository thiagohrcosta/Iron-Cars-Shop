require "test_helper"

class Admin::LeadsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(
      email: "admin@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Admin User",
      document_id: "11122233344",
      phone_number: "5554443333",
      address_street: "Admin Ave",
      address_number: "42",
      address_neighborhood: "Center",
      address_city: "Miami",
      address_state: "FL",
      address_zip_code: "33101",
      address_country: "US",
      role: :admin
    )

    @lead = leads(:one)
  end

  test "admin can view leads board" do
    sign_in @admin

    get admin_leads_url

    assert_response :success
    assert_includes response.body, "Leads Management"
    assert_includes response.body, @lead.name
  end

  test "admin can move a lead to another status" do
    sign_in @admin

    patch update_status_admin_lead_url(@lead), params: { status: "qualified" }

    assert_redirected_to admin_leads_url(anchor: "lead_#{@lead.id}")
    assert_equal "qualified", @lead.reload.status
  end
end
