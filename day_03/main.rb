# frozen_string_literal: true

class FileReader
  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def read_file_lines
    raise IOError, "File #{file_name} not found" unless File.exist?(file)

    File.readlines(file)
  end

  private

  def file
    File.join(__dir__, file_name)
  end
end

class BatteryBankParser
  attr_reader :raw_battery_banks

  def initialize(raw_battery_banks)
    @raw_battery_banks = raw_battery_banks
    validate_raw_battery_banks
  end

  def parsed_battery_banks
    raw_battery_banks.map { |battery_bank| parse_battery_bank(battery_bank) }
  end
  alias battery_banks parsed_battery_banks

  private

  def parse_battery_bank(battery_bank)
    battery_bank.chomp.split('').map(&:to_i)
  end

  def validate_raw_battery_banks
    raise StandardError, 'raw_battery_banks must be an array' unless raw_battery_banks.is_a?(Array)
    raise StandardError, 'raw_battery_banks must not be empty' if raw_battery_banks.empty?
  end
end

class PartOneSolver
  attr_reader :battery_banks

  def initialize(battery_banks)
    @battery_banks = battery_banks
  end

  def run
    joltages = []

    battery_banks.each do |battery_bank|
      joltage = find_joltage_for_bank(battery_bank)
      joltages << joltage
    end

    joltages.sum
  end

  private

  def find_joltage_for_bank(battery_bank)
    battery_a, battery_b = battery_bank.max(2)

    # the greatest value in the array is last; the second-greatest is before it
    # ex: 12341119
    # battery_a = 9
    # battery_b = 4
    # max joltage = 49
    return (battery_b.to_s + battery_a.to_s).to_i if battery_a == battery_bank.last

    battery_a_idx = battery_bank.index(battery_a)
    battery_b_idx = battery_bank.index(battery_b)

    # the greatest value in the array is before the second-greatest value
    # ex: 12391141
    # battery_a = 9
    # battery_b = 4
    # max joltage = 94
    return (battery_a.to_s + battery_b.to_s).to_i if battery_a_idx < battery_b_idx

    # the second-greatest value in the array is before the greatest value;
    # we need to find the greatest value _after_ the greatest value
    # ex: 12491121
    # battery_a = 9
    # battery_b = 4
    # next_biggest_battery = 2
    # max joltage = 92
    start_idx = battery_bank.index(battery_a) + 1
    remaining_batteries = battery_bank[start_idx..]
    next_biggest_battery = remaining_batteries.max

    (battery_a.to_s + next_biggest_battery.to_s).to_i
  end
end

def solve(input_file)
  puts "SOLVING FOR FILE: #{input_file}"

  raw_battery_banks = FileReader.new(input_file).read_file_lines
  battery_banks = BatteryBankParser.new(raw_battery_banks).battery_banks

  part_one = PartOneSolver.new(battery_banks).run
  puts "Part 1 Sum: #{part_one}"
end

INPUT_FILE = './input.txt'

solve(INPUT_FILE)
