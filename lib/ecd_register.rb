require 'csv'

class ECDRegister
  attr_accessor :group, :date, :number, :kind, :order, :code, :predecessor_code, :description

  def initialize(params)
    _null, @group, @date, @number, @kind, @order, @code, @predecessor_code, @description = params.split("|")
  end

  def generate_next
    ECDRegister.new "|#{@group}|#{@date}|#{@number}{|#{@kind}|#{@order.to_i + 1}|#{@code.to_s + "0"}|#{@code}|#{@description}|"
  end

  def to_s
    "|#{@group}|#{@date}|#{@number}{|#{@kind}|#{@order}|#{@code}|#{predecessor_code}|#{@description}|"
  end
end