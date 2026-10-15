class Admin::FinancialEntriesController < Admin::BaseController
  before_action :set_financial_entry, only: %i[show edit update destroy]

  def index
    @filters = params.permit(:q, :entry_type, :status, :origin, :starts_on, :ends_on)
    entries = FinancialEntry.order(due_date: :desc, created_at: :desc)
    entries = entries.where(entry_type: @filters[:entry_type]) if @filters[:entry_type].in?(FinancialEntry.entry_types.keys)
    entries = entries.where(status: @filters[:status]) if @filters[:status].in?(FinancialEntry.statuses.keys)
    entries = entries.where(automatic: @filters[:origin] == "automatic") if @filters[:origin].in?(%w[automatic manual])
    entries = entries.where("description LIKE ?", "%#{@filters[:q]}%") if @filters[:q].present?
    entries = entries.where("due_date >= ?", @filters[:starts_on]) if @filters[:starts_on].present?
    entries = entries.where("due_date <= ?", @filters[:ends_on]) if @filters[:ends_on].present?
    @income_entries = entries.income
    @expense_entries = entries.expense
    @income_total = @income_entries.sum(:amount)
    @expense_total = @expense_entries.sum(:amount)
  end

  def new
    @financial_entry = FinancialEntry.new(entry_type: :expense, status: :pending, due_date: Time.zone.today)
  end

  def show; end

  def create
    @financial_entry = FinancialEntry.new(financial_entry_params.merge(automatic: false))
    return redirect_to admin_financial_entries_path, notice: "Lançamento criado." if @financial_entry.save

    render :new, status: :unprocessable_entity
  end

  def edit
    return redirect_to admin_financial_entries_path, alert: "Lançamentos automáticos só podem ser alterados pelo pedido." if @financial_entry.automatic?
  end

  def update
    return redirect_to admin_financial_entries_path, alert: "Lançamentos automáticos só podem ser alterados pelo pedido." if @financial_entry.automatic?
    return redirect_to admin_financial_entries_path, notice: "Lançamento atualizado." if @financial_entry.update(financial_entry_params)

    render :edit, status: :unprocessable_entity
  end

  def destroy
    return redirect_to admin_financial_entries_path, alert: "Lançamentos automáticos não podem ser excluídos aqui." if @financial_entry.automatic?

    @financial_entry.destroy
    redirect_to admin_financial_entries_path, notice: "Lançamento removido."
  end

  private

  def set_financial_entry = @financial_entry = FinancialEntry.find(params[:id])
  def financial_entry_params = params.require(:financial_entry).permit(:description, :entry_type, :status, :amount, :due_date, :paid_at, :notes)
end
