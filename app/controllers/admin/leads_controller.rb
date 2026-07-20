class Admin::LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_lead, only: [ :distribute, :confirm_distribution, :retry_distribution, :update, :update_status ]

  def index
    @new_lead = Lead.new(source: :referral, status: :new)
    load_board
  end

  def create
    @new_lead = Lead.new(lead_params)
    @new_lead.source = :referral
    @new_lead.status = :new

    if @new_lead.save
      redirect_to admin_leads_path(anchor: "lead_#{@new_lead.id}"), notice: "#{@new_lead.name} was added successfully."
    else
      @show_new_lead_modal = true
      load_board
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @lead.update(lead_params)
      redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), notice: "#{@lead.name} was updated successfully."
    else
      redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), alert: @lead.errors.full_messages.to_sentence
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
    service = Admin::LeadDistributionService.new(lead: @lead, actor: current_user)
    result = service.call(strategy: :primary)
    result = service.call(strategy: :expanded) if !result.success? && !result.suggested?

    handle_distribution_result(result)
  end

  def retry_distribution
    handle_distribution_result(
      Admin::LeadDistributionService.new(lead: @lead, actor: current_user).call(strategy: :expanded)
    )
  end

  def confirm_distribution
    listing = VehicleListing.find(params.require(:listing_id))
    result = Admin::LeadDistributionService.new(lead: @lead, actor: current_user).confirm!(listing: listing)
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

  def lead_params
    params.require(:lead).permit(:name, :email, :phone, interested_in: [])
  end

  def load_board
    @leads = Lead.includes(:matched_vehicle_listing, :matched_seller, negotiations: :negotiation_messages)
      .order(updated_at: :desc, created_at: :desc)
    @leads_by_stage = Lead::PIPELINE_STAGES.index_with do |stage|
      @leads.select { |lead| lead.pipeline_stage == stage }
    end
  end

  def handle_distribution_result(result)
    if result.success?
      redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), notice: result.message
    elsif result.suggested?
      @new_lead = Lead.new(source: :referral, status: :new)
      @distribution_recommendation = result
      @show_distribution_modal = true
      load_board
      render :index, status: :ok
    else
      redirect_to admin_leads_path(anchor: "lead_#{@lead.id}"), alert: result.message
    end
  end
end
