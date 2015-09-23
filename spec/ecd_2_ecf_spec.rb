require 'ecd_2_ecf'
require 'ecd_table'

RSpec.describe Ecd2Ecf do

  before do
    # Create tmp dirs for tests
    Dir.mkdir('output') unless Dir.exists?('output')
    Dir.mkdir('output/spec') unless Dir.exists?('output/spec')

    table = ECDTable.new("spec/tabela_ecd_sample.csv")
    @converter = Ecd2Ecf.new(table)
  end

  it "convert an ECD file to an ECF file" do
    input = 'spec/ecd_sample.txt'
    output = 'output/spec/ecf_sample.txt'

    File.delete(output) if File.exists?(output)

    @converter.convert(input, output)

    result = File.read(output)
    # expect(result).to include("|J051|4||11111|")
    # expect(result).to include("|J050|01012014|01|S|2|11|1|CIRCULANTE|")
    # expect(result).to include("|J990|29|")
    expect(result).to eq(File.read("spec/ecf_expected_result.txt"))
  end

end
