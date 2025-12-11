# frozen_string_literal: true

require 'csv'

class FileReader
  attr_reader :file_name

  def initialize(file_name)
    @file_name = file_name
  end

  def read_file
    raise IOError, "File #{file_name} not found" unless File.exist?(file)

    file_string = File.read(file)
    CSV.parse(file_string)
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

  private

  def id_invalid?(id)
    # only ids divisible by 2 are candidates
    return false unless id.length.even?

    first_half, second_half = split_in_half(id)
    first_half == second_half
  end

  def split_in_half(str)
    half_length = (str.length + 1) / 2
    first_half = str[0, half_length]
    second_half = str[half_length..]
    [first_half, second_half]
  end

  def full_range
    Array(range_start..range_end)
  end
end

class PartOneSolver
  attr_reader :ranges
  attr_accessor :invalid_ids

  def initialize(ranges)
    @ranges = ranges
    @invalid_ids = []
  end

  def run
    ranges.each do |range|
      @invalid_ids << RangeChecker.new(range).invalid_ids
    end

    @invalid_ids.flatten.map(&:to_i)
  end
end

def solve(input_file)
  puts "SOLVING FOR FILE: #{input_file}"

  raw_ranges = FileReader.new(input_file).read_file
  ranges = RangeParser.new(raw_ranges).ranges

  invalid_ids = PartOneSolver.new(ranges).run
  puts "Sum: #{invalid_ids.sum}"
end

INPUT_FILE = './input.txt'

solve(INPUT_FILE)
