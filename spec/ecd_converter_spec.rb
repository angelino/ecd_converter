require 'ecd_converter'
require 'ecd_table'

RSpec.describe ECDConverter do

  before do
    # Create tmp dirs for tests
    Dir.mkdir('output') unless Dir.exists?('output')
    Dir.mkdir('output/spec') unless Dir.exists?('output/spec')

    table = ECDTable.new("spec/tabela_ecd_sample.csv")
    @converter = ECDConverter.new(table)
  end

  it "convert the old format to new format expected by ECD" do
    input = 'spec/ecd_sample.txt'
    output = 'output/spec/ecd_sample_convertido.txt'

    File.delete(output) if File.exists?(output)

    @converter.convert(input, output)

    result = File.read(output)
    expect(result).to include("|I051|4||1.01.01.01|")
    expect(result).to include("|I051|4||1.01.01.02|")
  end

end
