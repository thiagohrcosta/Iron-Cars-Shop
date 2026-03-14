require "test_helper"

class AgentLeadServiceTest < ActiveSupport::TestCase
  class FakeClient
    def create_json_response!(**)
      {
        response_id: "resp_123",
        parsed: {
          assistant_message: "Thanks, Taylor. I already found a few great options.",
          name: "Taylor",
          email: "taylor@example.com",
          phone: nil,
          interested_in: [ "Fiat", "2025", "4 doors", "New York" ],
          should_create_lead: true
        }
      }
    end
  end

  test "creates a lead when the minimum data is available" do
    service = AgentLeadService.new(
      message: "I need a 2025 Fiat with 4 doors in New York",
      state: {},
      client: FakeClient.new
    )

    assert_difference("Lead.count", 1) do
      result = service.call

      assert_equal true, result[:lead_created]
      assert_equal "taylor@example.com", result[:collected]["email"]
      assert_includes result[:assistant_message], "specialized agent"
    end

    lead = Lead.order(:created_at).last
    assert_equal [ "Fiat", "2025", "4 doors", "New York" ], lead.interested_in
    assert_equal "agent_lead", lead.source
  end
end
