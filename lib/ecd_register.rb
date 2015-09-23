require 'csv'

class ECDRegister
  attr_accessor :group, :date, :number, :kind, :order, :code, :predecessor_code, :description, :table

  def initialize(params, table=nil)
    _null, @group, @date, @number, @kind, @order, @code, @predecessor_code, @description = params.split("|")
    @table = table
  end

  def generate_next
    ECDRegister.new "|#{@group}|#{@date}|#{@number}|#{@kind}|#{@order.to_i + 1}|#{@code.to_s + "0"}|#{@code}|#{@description}|"
  end

  def generate_j051_line
    if kind == 'A' && @table
      return "|J051|||#{@table.find(prefix)}|"
    elsif kind == 'A'
      return "|J051|||#{prefix}|"
    end
    return nil
  end

  # Remove o ultimo agrupamento de zeros do 'code'
  def prefix
    end_of_prefix_index = code.rindex(/[^0](0)\1*([^2-9]|$)$/)
    unless(end_of_prefix_index)
      end_of_prefix_index = code.size
    end
    code[0..end_of_prefix_index]
  end

  def fix_myself_based_on_predecessor(predecessor_register)
    @order = (predecessor_register.order.to_i + 1).to_s
    @code  = predecessor_register.code.to_s + "0"
    @predecessor_code = predecessor_register.code
  end

  def to_s
    "|#{@group}|#{@date}|#{@number}|#{@kind}|#{@order}|#{@code}|#{predecessor_code}|#{@description}|"
  end
end
