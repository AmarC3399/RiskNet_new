class CustomersController < ApplicationController


   before_action :set_customer, only: [:show, :edit, :update, :destroy]
  # respond_to :json

  # # GET /customers.json
  def index
    @calc_limit = 20
    calc_offset = ([params[:page].to_i.abs, 1].max - 1) * @calc_limit
      
    case current_user&.owner_type
      when 'Installation'
        @customers = MemberAuthorizer::Scope.new(params, Member).resources
      when 'Member'
        @customers = ClientAuthorizer::Scope.new(params, Client).resources
      when 'Client'
        @customers = MerchantAuthorizer::Scope.new(params, Merchant).resolve
    end

    @customers = @customers&.limit(calc_limit)&.offset(calc_offset || 0)
    @total_items = @customers&.except(:limit, :offset)&.count

    @customers = Customer.new.build_json(@customers)

    respond_to do |format|
      format.html
      format.json {render json: {customers: @customers, meta: page_meta_info(@total_items, @calc_limit, params[:page])}.as_json, status: :ok}
    end
  end

  # # GET /customers/1.json
  def show
    @customers = Customer.find(params[:id])
    respond_to do  |format|
      format.html
      format.json {render json: @customers, include: [:cards, :comments]}
    end 
    
  end

  # # GET /customers/new
  def new
    @customer = Customer.new
  end

  # # GET /customers/1/edit
  def edit
  end

  # # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      respond_to do |format|
        format.html 
        format.json {render json: @customer, status: :created}
      end
      
    else
      respond_to do |format|
        format.html 
        format.json {render json: @customer.errors.full_messages, status: :unprocessable_entity}
      end
      
    end
  end

  # # PATCH/PUT /customers/1.json
  def update
    if @customer.update(customer_params)
      respond_to do |format|
        format.html 
        format.json render json: { head: :no_content }
      end
      
    else
      respond_to do |format|
        format.html 
        format.json {render json: @customer.errors.full_messages, status: :unprocessable_entity}
      end
      
    end
  end

  # # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html
      format.json {render json: @customers.to_json}
    end
    
  end

  private
  # Use callbacks to share common setup or constraint between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # # Never trust parameters from the scary internet, only allow the white list through.
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :address1, :address2, :postcode, :telephone, :country)
  end

  # Installation -> Installation
  # Member -> Client
  # Client -> Merchant
  # Merchant -> Sub-Merchant

  def member
    return_response(Member.all)
  end

  # This method will return list of clients along with its associated merchants
  # for instance
  # [
  #     {
  #         id: 1,
  #         client_name: 'John Lewis',
  #         has_many_merchants: [
  #             {
  #                 id: 1,
  #                 merchant_name: 'Home Department',
  #                 compnay_reg: 5314
  #             },
  #
  #             {
  #                 id: 2,
  #                 merchant_name: 'Sports Department',
  #                 company_reg: 123
  #             }
  #         ]
  #     },
  #
  #     {
  #         id: 2,
  #         client_name: 'Spots Direct',
  #         has_many_merchants: [
  #             {
  #                 id: 9,
  #                 merchant_name: 'Clothing',
  #                 compnay_reg: 981
  #             },
  #
  #             {
  #                 id: 10,
  #                 merchant_name: 'Golf',
  #                 company_reg: 2910
  #             }
  #         ]
  #     }
  # ]
  #
  #
  def client_with_many_merchants
    return_response(Client.get_client_with_many_merchants)
  end

  def merchants
    return_response(Merchant.all)
  end

end
