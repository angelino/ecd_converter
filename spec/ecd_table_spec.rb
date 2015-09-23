require 'ecd_table'

RSpec.describe ECDTable do

  context "creates a table based on csv file" do

    before do
      @table = ECDTable.new("spec/tabela_ecd_sample.csv")
    end

    it "contains all elements of base file" do
      expect(@table.entries.size).to eq(12)
    end

    it  "the first entrie is the headers" do
      expect(@table.entries.first).to eq(["Cod Refer", "ECF"])
    end

    it  "find an entrie by cod" do
      expect(@table.find("391111")).to eq("3.03.01")
      expect(@table.find("381111")).to eq(nil)
      expect(@table.find("11137")).to eq("1.01.01.03")
    end

  end
end
