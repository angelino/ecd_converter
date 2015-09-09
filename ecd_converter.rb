puts "ECD Converter"

contents = File.read('ecd.txt')
puts "Arquivo lido"

result = contents.gsub(//,'')
puts "Arquivo alterado"

File.write('ecd.txt', 'w') do |f|
  f.write(result)
end
puts "Arquivo gravado"

puts "Fim"
