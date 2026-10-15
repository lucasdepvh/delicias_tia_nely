class Admin::CustomersController < Admin::BaseController
  before_action :set_customer, only: %i[show edit update destroy]

  def index
    @customers = Customer.order(:name)
  end

  def show; end
  def edit; end

  def update
    return redirect_to admin_customer_path(@customer), notice: "Cliente atualizado." if @customer.update(customer_params)

    render :edit, status: :unprocessable_entity
  end

  def destroy
    @customer.destroy
    redirect_to admin_customers_path, notice: @customer.errors.any? ? @customer.errors.full_messages.to_sentence : "Cliente removido."
  end

  private

  def set_customer = @customer = Customer.find(params[:id])
  def customer_params = params.require(:customer).permit(:name, :phone, :email, :zip_code, :street, :number, :neighborhood, :city, :state, :complement, :reference, :notes)
end
