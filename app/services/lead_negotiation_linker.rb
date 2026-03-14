class LeadNegotiationLinker
  def initialize(user:)
    @user = user
  end

  def call
    return 0 if @user.email.blank?

    scope = negotiations_to_link
    count = scope.count

    scope.find_each do |negotiation|
      negotiation.update!(buyer: @user)
    end

    count
  end

  private

  def negotiations_to_link
    Negotiation
      .where(buyer_id: nil)
      .joins(:lead)
      .where(leads: { email: @user.email.to_s.strip.downcase })
  end
end
