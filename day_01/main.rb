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

class RotationParser
  attr_reader :raw_rotations

  def initialize(raw_rotations)
    @raw_rotations = raw_rotations
    validate_raw_rotations
  end

  def parsed_rotations
    raw_rotations.map { |rotation| parse_rotation(rotation) }
  end
  alias rotations parsed_rotations

  private

  def parse_rotation(line)
    direction, clicks = line.scan(/[A-Za-z]+|\d+/)
    validate_rotation(direction, clicks)

    rotation_num = clicks.to_i
    rotation_num = -rotation_num if direction == 'L'

    rotation_num # "L24" -> -24; "R15" -> 15
  end

  def validate_rotation(direction, clicks)
    raise StandardError, 'Rotation direction must be L or R' unless %w[L R].any?(direction)
    raise StandardError, 'Rotation must include clicks.' if clicks.nil?
  end

  def validate_raw_rotations
    raise StandardError, 'raw_rotations must be an array' unless raw_rotations.is_a?(Array)
    raise StandardError, 'raw_rotations must not be empty' if raw_rotations.empty?
  end
end

class Rotator
  MIN_POSITION = 0
  MAX_POSITION = 99
  DEFAULT_STARTING_POSITION = 50

  attr_reader :all_positions, :starting_position
  attr_accessor :end_positions

  def initialize
    @all_positions = [*MIN_POSITION..MAX_POSITION]
    @starting_position = DEFAULT_STARTING_POSITION
    @end_positions = [starting_position]
  end

  def complete_rotations(rotations)
    rotations.each { |rotation| rotate(rotation) }
  end

  def num_zero_positions
    end_positions.count(&:zero?)
  end

  private

  def rotate(rotation_num)
    new_index = get_new_position_index(rotation_num)

    end_positions << all_positions[new_index]
  end

  def get_new_position_index(rotation_num)
    current_position = end_positions.last
    (current_position + rotation_num) % all_positions.length
  end
end

INPUT_FILE = './input.txt'

def answer
  raw_rotations = FileReader.new(INPUT_FILE).read_file_lines
  rotations = RotationParser.new(raw_rotations).rotations

  rotator = Rotator.new
  rotator.complete_rotations(rotations)
  rotator.num_zero_positions
end

puts "ANSWER: #{answer}"
