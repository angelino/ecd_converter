require 'csv'

class ECDTable
  attr_reader :filename, :rejected

  def initialize(filename)
    @filename = filename
    @rejected = []
  end

  def entries
    @entries ||= Hash[data.entries]
  end

  def find(cod)
    if entries[cod].nil?
      rejected << cod
    end
    entries[cod]
  end

  private

  def data
    @data ||= CSV.open(filename, 'r', encoding: 'ISO-8859-1', col_sep: ',')
  end
end
