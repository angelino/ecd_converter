puts "ECD Converter"

PATTERN = /\|I051\|\w\|\|\d+\|/

require 'csv'

filename = 'tabela_ecd.csv'
data = CSV.open(filename, 'r', encoding: 'utf-8', col_sep: ','
  # , headers: true, header_converters: :symbol
  )

COD_TABLE = Hash[data.entries]

def find(cod)
  COD_TABLE[cod]
end

content = File.read('ecd.txt')
puts "Arquivo lido"

replaceable_lines = content.scan(PATTERN)

replaceable_lines.uniq.each do |old_line|
  cod_ref = old_line.split('|').last
  new_cod = find(cod_ref)
  new_line = old_line.sub(cod_ref, new_cod) if new_cod

  content.gsub!(old_line, new_line) if new_line
end
puts "Arquivo alterado"

File.open('ecd.txt', 'w') do |f|
  f.write(content)
end
puts "Arquivo gravado"

puts "Fim"
