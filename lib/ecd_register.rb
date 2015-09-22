require 'csv'

class ECDRegister
  attr_accessor :group, :date, :number, :kind, :order, :code, :predecessor_code, :description

  def initialize(params)
    _null, @group, @date, @number, @kind, @order, @code, @predecessor_code, @description = params.split("|")
  end

  def generate_next
    ECDRegister.new "|#{@group}|#{@date}|#{@number}{|#{@kind}|#{@order.to_i + 1}|#{@code.to_s + "0"}|#{@code}|#{@description}|"
  end

  def fix_myself_based_on_predecessor(predecessor_register)
    @order = predecessor_register.order.to_i + 1
    @code  = predecessor_register.code.to_s + "0"
    @predecessor_code = predecessor_register.code
  end

  def to_s
    "|#{@group}|#{@date}|#{@number}{|#{@kind}|#{@order}|#{@code}|#{predecessor_code}|#{@description}|"
  end
end