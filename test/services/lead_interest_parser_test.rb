require "test_helper"

class LeadInterestParserTest < ActiveSupport::TestCase
  test "parses freeform brand and state entries into searchable filters" do
    seller = User.create!(
      email: "parser-seller@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      full_name: "Parser Seller",
      document_id: "81122334455",
      phone_number: "5551234567",
      address_street: "Sunset Blvd",
      address_number: "10",
      address_neighborhood: "West",
      address_city: "Los Angeles",
      address_state: "CA",
      address_zip_code: "90001",
      address_country: "US"
    )

    Brand.create!(
      user: seller,
      name: "Mercedes-Benz",
      slug: "mercedes-benz-parser",
      description: "Mercedes-Benz",
      country: "Germany",
      founded_in: "1926"
    )

    filters = LeadInterestParser.new([ "Mercedes", "California" ]).to_filters

    assert_equal "Mercedes-Benz", filters[:brand]
    assert_equal "CA", filters[:state]
  end
end
