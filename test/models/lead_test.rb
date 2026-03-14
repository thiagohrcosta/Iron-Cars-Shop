require "test_helper"

class LeadTest < ActiveSupport::TestCase
  test "normalizes email and interested_in values" do
    lead = Lead.new(
      name: "Chris Doe",
      email: "  CHRIS@Example.COM ",
      interested_in: [ " Fiat ", "", "2025", "Fiat" ]
    )

    assert lead.valid?
    assert_equal "chris@example.com", lead.email
    assert_equal [ "Fiat", "2025" ], lead.interested_in
  end
end
