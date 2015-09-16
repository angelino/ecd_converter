require 'csv'

class ECDTable
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def entries
    @entries ||= Hash[data.entries]
  end

  def find(cod)
    entries[cod]
  end

  private

  def data
    @data ||= CSV.open(filename, 'r', encoding: 'utf-8', col_sep: ',')
  end
end
