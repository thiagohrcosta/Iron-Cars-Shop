require "test_helper"

module Admin
  class LeadDistributionServiceTest < ActiveSupport::TestCase
    test "returns a broader-search suggestion when only a higher priced close match exists" do
      admin = create_user!(
        email: "admin-distribution@example.com",
        role: :admin,
        document_id: "90011122233"
      )
      seller = create_user!(
        email: "seller-distribution@example.com",
        document_id: "90011122234",
        address_city: "Los Angeles",
        address_state: "CA"
      )

      brand = Brand.create!(
        user: seller,
        name: "BMW",
        slug: "bmw-distribution",
        description: "BMW",
        country: "Germany",
        founded_in: "1916"
      )

      car_model = CarModel.create!(
        user: seller,
        brand: brand,
        name: "M4 Competition",
        slug: "m4-competition-distribution",
        description: "M4",
        body_type: :coupe
      )

      vehicle = Vehicle.create!(
        user: seller,
        car_model: car_model,
        vin: "99999123451234567",
        year: 2025,
        mileage: 2_000,
        exterior_color: "black",
        transmission: :automatic,
        fuel_type: :gasoline,
        drivetrain: :rwd,
        condition: :used,
        title_status: :clean,
        price_cents: 80_000_000,
        currency: :usd
      )

      listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
      lead = Lead.create!(
        name: "John Smith",
        email: "johnsmith@example.com",
        interested_in: [ "brand:BMW", "model:M4", "budget:450000", "city:Los Angeles" ],
        source: :agent_lead,
        status: :new
      )

      result = LeadDistributionService.new(lead: lead, actor: admin).call(strategy: :expanded)

      assert_not result.success?
      assert result.suggested?
      assert_equal listing, result.listing
      assert_equal "expanded", result.strategy
      assert_includes result.tradeoffs.join(" "), "above the requested budget"
    end

    test "confirming a suggestion distributes the lead" do
      admin = create_user!(
        email: "admin-confirm@example.com",
        role: :admin,
        document_id: "90011122235"
      )
      seller = create_user!(
        email: "seller-confirm@example.com",
        document_id: "90011122236"
      )

      brand = Brand.create!(
        user: seller,
        name: "Porsche",
        slug: "porsche-confirm",
        description: "Porsche",
        country: "Germany",
        founded_in: "1931"
      )

      car_model = CarModel.create!(
        user: seller,
        brand: brand,
        name: "911 Carrera",
        slug: "911-carrera-confirm",
        description: "911",
        body_type: :coupe
      )

      vehicle = Vehicle.create!(
        user: seller,
        car_model: car_model,
        vin: "99999123451234568",
        year: 2024,
        mileage: 5_000,
        exterior_color: "silver",
        transmission: :automatic,
        fuel_type: :gasoline,
        drivetrain: :rwd,
        condition: :used,
        title_status: :clean,
        price_cents: 95_000_00,
        currency: :usd
      )

      listing = VehicleListing.create!(vehicle: vehicle, seller: seller, status: :published)
      lead = Lead.create!(
        name: "Manual Confirm",
        email: "manualconfirm@example.com",
        interested_in: [ "brand:Porsche", "model:911", "budget:45000" ],
        source: :referral,
        status: :new
      )

      result = LeadDistributionService.new(lead: lead, actor: admin).confirm!(listing: listing)

      assert result.success?
      assert_equal listing, lead.reload.matched_vehicle_listing
      assert_equal seller, lead.reload.matched_seller
      assert lead.distributed?
      assert_equal "contacted", lead.status
    end

    private

    def create_user!(email:, document_id:, role: :user, address_city: "Miami", address_state: "FL")
      User.create!(
        email: email,
        password: "Password123!",
        password_confirmation: "Password123!",
        full_name: email.split("@").first.tr(".", " ").titleize,
        document_id: document_id,
        phone_number: "5551212121",
        address_street: "Market St",
        address_number: "100",
        address_neighborhood: "Central",
        address_city: address_city,
        address_state: address_state,
        address_zip_code: "33101",
        address_country: "US",
        role: role
      )
    end
  end
end
