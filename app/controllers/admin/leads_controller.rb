class Admin::LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_lead, only: [ :distribute, :update_status ]

  def index
    @leads = Lead.includes(:matched_vehicle_listing, :matched_seller, negotiations: :negotiation_messages)
      .order(updated_at: :desc, created_at: :desc)
    @leads_by_stage = Lead::PIPELINE_STAGES.index_with do |stage|
      @leads.select { |lead| lead.pipeline_stage == stage }
    end
  end

  def update_status
    status = params.require(:status).to_s

    unless Lead.statuses.key?(status)
      redirect_to admin_leads_path, alert: "Invalid lead status." and return
    end

    @lead.update!(status: status)
    redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), notice: "#{@lead.name} moved to #{status.humanize}."
  end

  def distribute
    result = Admin::LeadDistributionService.new(lead: @lead, actor: current_user).call
    flash_key = result.success? ? :notice : :alert
    redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), flash_key => result.message
  end

  private

  def require_admin!
    redirect_to user_dashboard_path unless current_user.admin?
  end

  def set_lead
    @lead = Lead.find(params[:id])
  end
end
