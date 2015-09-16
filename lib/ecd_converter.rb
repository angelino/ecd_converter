class ECDConverter
  PATTERN = /\|I051\|\w\|\|\d+\|/

  attr_reader :table

  def initialize(table)
    @table = table
  end

  def convert(input_filename, output_filename)
    puts "Inicio da Conversao..."

    content = read(input_filename)

    replaceable_lines(content).each do |old_line|
      cod_ref = old_line.split('|').last
      new_cod = @table.find(cod_ref)
      new_line = old_line.sub(cod_ref, new_cod) if new_cod

      content.gsub!(old_line, new_line) if new_line
    end
    puts "Valores alterados..."

    write(content, output_filename)

    puts "Fim da Conversao"
  end

  private

  def read(filename)
    content = File.read(filename)
    puts "Arquivo #{filename} lido..."
    content
  end

  def write(content, filename)
    File.open(filename, 'w') do |f|
      f.write(content)
    end
    puts "Arquivo convertido armazenado em #{filename}"
  end

  def replaceable_lines(content)
    content.scan(PATTERN).uniq
  end

end













