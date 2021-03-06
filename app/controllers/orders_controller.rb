class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    @iphones = Iphone.all
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    if logged_in?
      @order = Order.new
      @order.user_email = current_user.email
      @order.gift_card = params[:itunesCodes]

      if(!params[:promocode].nil?)
        @order.promocode = params[:promocode]
      end
      if params[:model].downcase.include? "mac"
        order_mac
      elsif  params[:model].downcase.include? "iphone"
        order_iphone
      else 
        order_watch
      end 
      respond_to do |format|
      if @order.save
        UserMailer.notify(current_user, @order).deliver
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
    else flash.now[:danger] = 'You need to login before placing an order!'
    end
  end

  def order_iphone
    @order.product_size = params[:size]
    @order.product_color = params[:color]
    @current_iphone = nil
    if params[:model].nil?
      @order.product_type = 'SE'
      @current_iphone = Iphone.where(phone_type: 'SE').where(size: params[:size]).where(color: params[:color]).first
    else
      @order.product_type = params[:model]
      product_models = @order.product_type.split("-")
      @current_iphone = Iphone.where(phone_type: product_models[1]).where(model: product_models[2]).where(size: @order.product_size).where(color: @order.product_color).first
    end
    @order.amount = @current_iphone.price
    if(!@order.promocode.nil?)
      current_promocode = Promocode.where(promovalue: params[:promocode]).first
      if(!current_promocode.nil?)
        discount = @order.amount - @order.amount * current_promocode.promotype * 0.01
        @order.amount = discount
      end
    end
  end

  def order_mac
    @order.product_type = params[:model]
    @order.product_size = params[:size]
    @order.product_color = params[:color]
    @order.amount = params[:price]

    if(!@order.promocode.nil?)
      current_promocode = Promocode.where(promovalue: params[:promocode]).first
      if(!current_promocode.nil?)
        discount = @order.amount - @order.amount * current_promocode.promotype * 0.01
        @order.amount = discount
      end
    end
  end

  def order_watch
    @order.product_type = params[:model]
    @order.product_size = params[:size]
    @order.product_color = params[:color]
    @order.amount = params[:price]

    if(!@order.promocode.nil?)
      current_promocode = Promocode.where(promovalue: params[:promocode]).first
      if(!current_promocode.nil?)
        discount = @order.amount - @order.amount * current_promocode.promotype * 0.01
        @order.amount = discount
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        OrderMailer.order_submission_email(current_user, @order).deliver
        #format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        #format.html { render :edit }
        flash.now[:danger] = 'The order could not be updated !'
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def current_price
     #product_models = params[:model].split("-")
     #current_configuration= Iphone.where(phone_type: product_models[1]).where(model: product_models[2]).where(size: params[:size]).where(color: params[:color]).first
     #return current_configuration.price
     return params[:model]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:user_id, :user_email, :iphone_id, :mac_id, :watch_id, :product_type, :product_size, :product_color, :amount, :promocode, :gift_card)
    end
end
