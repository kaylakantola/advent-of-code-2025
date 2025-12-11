# frozen_string_literal: true

require 'csv'
require 'prime'

class FileReader
  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def read_file
    raise IOError, "File #{file_name} not found" unless File.exist?(file)

    CSV.parse(File.read(file))
  end

  private

  def file
    File.join(__dir__, file_name)
  end
end

class RangeParser
  attr_reader :raw_ranges

  def initialize(raw_ranges)
    @raw_ranges = raw_ranges.first
    validate_raw_ranges
  end

  def parsed_ranges
    raw_ranges.map { |range| parse_range(range) }
  end
  alias ranges parsed_ranges

  private

  def parse_range(range)
    range.split('-')
  end

  def validate_raw_ranges
    raise StandardError, 'raw_ranges must be an array' unless raw_ranges.is_a?(Array)
    raise StandardError, 'raw_ranges must not be empty' if raw_ranges.empty?
  end
end

class RangeChecker
  attr_reader :range_start, :range_end

  def initialize(range)
    @range_start = range[0]
    @range_end = range[1]
  end

  def invalid_ids
    full_range.select { |id| id_invalid?(id) }
  end

  def full_range
    Array(range_start..range_end)
  end
end

class RangeCheckerPart1 < RangeChecker
  private

  def id_invalid?(id)
    # only ids divisible by 2 are candidates
    return false unless id.length.even?

    first_half, second_half = split_in_half(id)
    first_half == second_half
  end

  def split_in_half(str)
    half_length = str.length / 2
    first_half = str[0, half_length]
    second_half = str[half_length..]
    [first_half, second_half]
  end
end

class RangeCheckerPart2 < RangeChecker
  private

  def id_invalid?(id)
    return false if id.length <= 1 # quick check - if there's only one character, no repeats possible; it's valid
    return true if id.chars.uniq.one? # quick check - if all the characters are the same, it's invalid
    return false if id.length.prime? # quick check - if number of characters is prime, no repeats possible; it's valid

    repeating_pattern?(id)
  end

  def repeating_pattern?(id)
    # Example: id = "456456456456"
    length = id.length # length = 12

    # Check divisors from 2 to 11 (exclude 1 and 12)
    # Divisors that divide 12 evenly: 2, 3, 4, 6
    (2...length).any? do |divisor|
      next unless (length % divisor).zero? # Skip if not an even divisor

      # fancy modulo math to check that repeated characters are in the right spots
      (divisor...length).all? { |i| id[i] == id[i % divisor] }

      # Example with divisor = 3 (pattern "456" repeated 4 times):
      #   i=3:  id[3] == id[3 % 3]  -->  id[3] == id[0]  -->  '4' == '4'  PASS
      #   i=4:  id[4] == id[4 % 3]  -->  id[4] == id[1]  -->  '5' == '5'  PASS
      #   i=5:  id[5] == id[5 % 3]  -->  id[5] == id[2]  -->  '6' == '6'  PASS
      #   i=6:  id[6] == id[6 % 3]  -->  id[6] == id[0]  -->  '4' == '4'  PASS
      #   i=7:  id[7] == id[7 % 3]  -->  id[7] == id[1]  -->  '5' == '5'  PASS
      #   i=8:  id[8] == id[8 % 3]  -->  id[8] == id[2]  -->  '6' == '6'  PASS
      #   i=9:  id[9] == id[9 % 3]  -->  id[9] == id[0]  -->  '4' == '4'  PASS
      #   i=10: id[10] == id[10 % 3] --> id[10] == id[1] --> '5' == '5'  PASS
      #   i=11: id[11] == id[11 % 3] --> id[11] == id[2] --> '6' == '6'  PASS
      #   All checks pass, so all? returns true
      #
      # Example with divisor = 2:
      #   i=2:  id[2] == id[2 % 2]  -->  id[2] == id[0]  -->  '6' == '4'  FAIL
      #   First check fails, so all? returns false immediately
    end
  end
end

class SolverHelper
  attr_reader :ranges, :range_checker

  def initialize(ranges, range_checker)
    @ranges = ranges
    @range_checker = range_checker
  end

  def run
    ranges.flat_map { |range| range_checker.new(range).invalid_ids }.map(&:to_i)
  end
end

def solve(input_file)
  puts "SOLVING FOR FILE: #{input_file}"

  raw_ranges = FileReader.new(input_file).read_file
  ranges = RangeParser.new(raw_ranges).ranges

  invalid_ids_part_one = SolverHelper.new(ranges, RangeCheckerPart1).run
  puts "Part 1 Sum: #{invalid_ids_part_one.sum}"

  invalid_ids_part_two = SolverHelper.new(ranges, RangeCheckerPart2).run
  puts "Part 2 Sum: #{invalid_ids_part_two.sum}"
end

INPUT_FILE = './input.txt'

solve(INPUT_FILE)
