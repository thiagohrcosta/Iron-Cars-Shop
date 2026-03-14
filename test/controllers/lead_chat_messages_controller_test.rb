require "test_helper"

class LeadChatMessagesControllerTest < ActionDispatch::IntegrationTest
  class FakeService
    def call
      {
        assistant_message: "I already found some promising vehicles here.",
        lead_created: true,
        lead_id: 77,
        conversation_closed: true,
        collected: {
          "name" => "Taylor",
          "email" => "taylor@example.com",
          "phone" => nil,
          "interested_in" => [ "Fiat", "2025", "New York" ]
        },
        session_state: {
        }
      }
    end
  end

  test "returns the assistant payload" do
    AgentLeadService.stub(:new, FakeService.new) do
      post lead_chat_messages_path, params: { message: "I want a Fiat" }, as: :json
    end

    assert_response :success

    payload = JSON.parse(response.body)
    assert_equal true, payload["lead_created"]
    assert_equal true, payload["conversation_closed"]
    assert_equal "taylor@example.com", payload.dig("collected", "email")
  end
end
