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

class Solver
  attr_reader :battery_banks, :batteries_needed

  def initialize(battery_banks, n_batteries)
    @battery_banks = battery_banks
    @batteries_needed = n_batteries
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
    result = []
    start_idx = 0

    batteries_needed.times do |position|
      next_max_battery = find_next_max_battery(battery_bank, position, start_idx)

      result << next_max_battery[:value]
      start_idx = next_max_battery[:index] + 1
    end

    result.join.to_i
  end

  def find_next_max_battery(battery_bank, position, start_idx)
    bank_size = battery_bank.length

    search_end = calculate_search_end(bank_size, position)

    # Find the maximum digit in the valid range
    search_range = battery_bank[start_idx...search_end]
    max_digit = search_range.max

    # Find the index of this max digit (relative to start_idx)
    relative_idx = search_range.index(max_digit)
    max_idx = start_idx + relative_idx

    { index: max_idx, value: max_digit }
  end
end

def calculate_search_end(bank_size, position)
  # Calculate how far we can search while leaving room for remaining batteries
  #
  # Example: battery_bank = [4,5,6,7,8,4,3,9,3,1,1,1] (indices 0-11)
  #   bank_size = 12
  #   batteries_needed = 4
  #   position = 2 (we've picked 2 batteries already, need 2 more including current)
  #
  #   After picking current battery, we still need: 4 - 2 - 1 = 1 more battery
  #   If we pick battery at index 10, we have index [11] left (1 battery) ✓
  #   If we pick battery at index 11, we have [] left (0 batteries) ✗
  #   So we can search up to index 10 (inclusive), or [start_idx...11] (exclusive)
  #
  #   Formula: 12 - 4 + 2 + 1 = 11 (the exclusive end of our search range)
  bank_size - batteries_needed + position + 1
end

def solve(input_file)
  puts "SOLVING FOR FILE: #{input_file}"

  raw_battery_banks = FileReader.new(input_file).read_file_lines
  battery_banks = BatteryBankParser.new(raw_battery_banks).battery_banks

  part_one = Solver.new(battery_banks, 2).run
  puts "Part 1 Sum: #{part_one}"

  part_two = Solver.new(battery_banks, 12).run
  puts "Part 2 Sum: #{part_two}"
end

INPUT_FILE = './input.txt'

solve(INPUT_FILE)
