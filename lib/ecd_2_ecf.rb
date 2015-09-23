require_relative './ecd_register'

class Ecd2Ecf
  attr_reader :table

  def initialize(table)
    @table = table
  end

  def convert(input_filename, output_filename)
    start_time = Time.now
    puts "#{start_time} - Starting creation of ECF..."

    content = read(input_filename)
    new_content = ''
    prepare_header(content, new_content)
    process_content(content, new_content)
    prepare_footer(new_content)

    write(new_content, output_filename)

    finish_time = Time.now
    puts "#{finish_time} - Finishing creation of ECF..."
    puts "Finished conversion in #{finish_time.tv_sec - start_time.tv_sec} seconds"
  end

  private

  def read(filename)
    content = File.read(filename)
    puts "File #{filename} read..."
    content
  end

  def write(content, filename)
    File.open(filename, 'w') do |f|
      f.write(content)
    end
    puts "File converted to #{filename}"
  end

  def prepare_header(content, new_content)
    first_ecd_line = content.lines.first
    dt1,dt2,name,cnpj = first_ecd_line.split('|')[3,4]
    puts "#{Time.now} - Preparing header of ECF"
    new_content << "|0000|LECF|0001|#{cnpj}|#{name}|0|0|||#{dt1}|#{dt2}|N||0||\n|0001|0|\n|0010||N|N|1|A|03|RRRR|BBEEEEBBBEEB|||||N||\n|0020|S||N|N|N|N|N|N|N|N|N|N|N|S|N|N|N|N|N|N|N|N|N|S|N|N|N|N|N|N|\n|0030|2054|6512000|BARAO DE ITAPAGIPE|225|PARTE|RIO COMPRIDO|RJ|3304557|20261901||grazielli.brasil@bradescoseguros.com.br|\n|0930|Getúlio Antonio Guidini|19718934049|900|1RS034447/O-7S|grazielli.brasil@bradescoseguros.com.br|001132655595|\n|0930|GRAZIELLI CAVALCANTE BRASIL|28863890803|309|||001132655595|\n|0990|8|\n|J001|0|\n"
  end

  def process_content(content, new_content)
    meaningful_registers = separate_meaningful_registers(content)
    fixed_registers = process_meaningful_registers(meaningful_registers)
    fixed_registers.each do |register|
      new_content << "#{register.to_s}\n"
    end

  end

  def process_meaningful_registers(meaningful_registers_lines)
    meaningful_registers = convert_meaningful_to_array(meaningful_registers_lines)
    meaningful_fixed_registers = []
    while(workload = extract_next_block(meaningful_registers))

      last  = workload.last
      pivot = { pivot: workload.shift }

      workload.each do |current|
        process_register(pivot, last, current, meaningful_fixed_registers)
        if(current.kind == 'A')
          puts "last element: #{current}"
          meaningful_fixed_registers.push(current)
          meaningful_fixed_registers.push(current.generate_j051_line)
        end
      end
    end
    return meaningful_fixed_registers
  end

  # FIXME: Review process
  def process_register(pivot, last, current, meaningful_fixed_registers)
    _pivot = pivot[:pivot]
    puts "pivot: #{_pivot}"

    if (_pivot.prefix == last.prefix)
      if(current.order.to_i > (_pivot.order.to_i + 1))
        meaningful_fixed_registers.push(_pivot)
        pivot[:pivot] = _pivot.generate_next
        process_register(pivot, last, current, meaningful_fixed_registers)
      else
        current.fix_myself_based_on_predecessor(_pivot)
        meaningful_fixed_registers.push(_pivot)
        pivot[:pivot] = current
      end
    else
      meaningful_fixed_registers.push(_pivot)
      pivot[:pivot] = current
    end
  end

  def extract_next_block(registers_array)
    last_block_element_index = -1
    registers_array.each_with_index do |element, index|
      if (element.kind == 'A')
        last_block_element_index = index
        break
      end
    end

    result = registers_array.slice!(0,last_block_element_index+1)

    if result.empty?
      return nil
    else
      return result
    end
  end

  def convert_meaningful_to_array(meaningful_registers_lines)
    all_meaningful_ecd_registers = []
    meaningful_registers_lines.each_line do |register_line|
      all_meaningful_ecd_registers.push ECDRegister.new(register_line, @table)
    end
    return all_meaningful_ecd_registers
  end

  def separate_meaningful_registers(content)
    meaningful = ""
    line_number = 1
    content.each_line do |register|
      meaningful << fix_register(register, line_number)
      line_number = line_number + 1
    end

    return meaningful
  end

  def fix_register(register, line_number)
    puts "#{Time.now} - Fixing register #{line_number}"
    register = cleanup_register(register)
    if(!register.nil? && !register.empty?)
      return "#{register.gsub(/(\|I050\|)/,"|J050|")}"
    end
    return ""
  end

  def cleanup_register(register)
    if(register.start_with?('|I050|'))
      return register
    end
    puts "#{Time.now} - Register cleaned"
    return ""
  end

  def prepare_footer(new_content)
    puts "#{Time.now} - Preparing footer of ECF"
    new_content << "|J990|#{count_registers(new_content)}|\n|9001|0|\n|9900|0000|1|0.06|ID_TAB_DIN|\n|9900|0001|1|0.06|ID_TAB_DIN|\n|9900|0010|1|0.06|ID_TAB_DIN|\n|9900|0020|1|0.06|ID_TAB_DIN|\n|9900|0030|1|0.06|ID_TAB_DIN|\n|9900|0930|2|0.06|ID_TAB_DIN|\n|9900|0990|1|0.06|ID_TAB_DIN|\n|9900|9001|1|0.06|ID_TAB_DIN|\n|9900|J001|1|0.06|ID_TAB_DIN|\n|9900|J050|1138|0.06|ID_TAB_DIN|\n|9900|J051|186|0.06|ID_TAB_DIN|\n|9900|J990|1|0.06|ID_TAB_DIN|\n|9900|K001|1|0.06|ID_TAB_DIN|\n|9900|K030|7|0.06|ID_TAB_DIN|\n|9900|K155|670|0.06|ID_TAB_DIN|\n|9900|K156|656|0.06|ID_TAB_DIN|\n|9900|K355|524|0.06|ID_TAB_DIN|\n|9900|K356|510|0.06|ID_TAB_DIN|\n|9900|K990|1|0.06|ID_TAB_DIN|\n|9900|L001|1|0.06|ID_TAB_DIN|\n|9900|L030|7|0.06|ID_TAB_DIN|\n|9900|L100|467|0.06|ID_TAB_DIN|\n|9900|L300|55|0.06|ID_TAB_DIN|\n|9900|L990|1|0.06|ID_TAB_DIN|\n|9900|M001|1|0.06|ID_TAB_DIN|\n|9900|M010|10|0.06|ID_TAB_DIN|\n|9900|M030|7|0.06|ID_TAB_DIN|\n|9900|M300|48|0.06|ID_TAB_DIN|\n|9900|M305|27|0.06|ID_TAB_DIN|\n|9900|M310|47|0.06|ID_TAB_DIN|\n|9900|M350|39|0.06|ID_TAB_DIN|\n|9900|M355|27|0.06|ID_TAB_DIN|\n|9900|M360|47|0.06|ID_TAB_DIN|\n|9900|M500|50|0.06|ID_TAB_DIN|\n|9900|M990|1|0.06|ID_TAB_DIN|\n|9900|N001|1|0.06|ID_TAB_DIN|\n|9900|N030|13|0.06|ID_TAB_DIN|\n|9900|N500|26|0.06|ID_TAB_DIN|\n|9900|N620|324|0.06|ID_TAB_DIN|\n|9900|N630|24|0.06|ID_TAB_DIN|\n|9900|N650|26|0.06|ID_TAB_DIN|\n|9900|N660|228|0.06|ID_TAB_DIN|\n|9900|N670|23|0.06|ID_TAB_DIN|\n|9900|N990|1|0.06|ID_TAB_DIN|\n|9900|X001|1|0.06|ID_TAB_DIN|\n|9900|X450|1|0.06|ID_TAB_DIN|\n|9900|X990|1|0.06|ID_TAB_DIN|\n|9900|Y001|1|0.06|ID_TAB_DIN|\n|9900|Y600|1|0.06|ID_TAB_DIN|\n|9900|Y611|1|0.06|ID_TAB_DIN|\n|9900|Y671|1|0.06|ID_TAB_DIN|\n|9900|Y990|1|0.06|ID_TAB_DIN|\n|9900|9900|54|0.06||\n|9900|9990|1|0.06|ID TAB DIN|"
  end

  def count_registers(content)
    puts "#{Time.now} - Counting |J050| and |J051| registers..."
    return content.scan(/(\|J051\|)|(\|J050\|)/).count
  end

end
