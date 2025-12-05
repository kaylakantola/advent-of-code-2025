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
  attr_accessor :end_positions, :times_passing_zero

  def initialize
    @all_positions = [*MIN_POSITION..MAX_POSITION]
    @starting_position = DEFAULT_STARTING_POSITION
    @end_positions = [starting_position]
    @times_passing_zero = []
  end

  def complete_rotations(rotations)
    rotations.each { |n| rotate(current_position: end_positions.last, rotation_num: n) }
  end

  def num_zero_positions
    end_positions.count(&:zero?)
  end

  def num_zero_clicks
    times_passing_zero.sum
  end

  private

  def rotate(current_position:, rotation_num:)
    loops, new_index = get_new_position_index(current_position, rotation_num)
    end_positions << all_positions[new_index]

    zero_count = count_zero_clicks(start_pos: current_position, end_pos: new_index, loops: loops.abs,
                                   left_rotation: rotation_num.negative?)
    times_passing_zero << zero_count
  end

  def get_new_position_index(current_position, rotation_num)
    (current_position + rotation_num).divmod(all_positions.length)
  end

  def count_zero_clicks(start_pos:, end_pos:, loops:, left_rotation:)
    zero_count = loops

    if left_rotation
      if start_pos.zero?
        # Starting at 0 going left: subtract 1 (we start at 0 but don't land on it)
        zero_count -= 1
      elsif end_pos.zero?
        # Ending at 0 going left: add 1 (we land on 0 but might not have wrapped)
        zero_count += 1
      end
    end

    zero_count
  end
end

def solve(input_file)
  puts "SOLVING FOR FILE: #{input_file}"

  raw_rotations = FileReader.new(input_file).read_file_lines
  rotations = RotationParser.new(raw_rotations).rotations

  rotator = Rotator.new
  rotator.complete_rotations(rotations)
  part_1_answer = rotator.num_zero_positions

  puts "PART 1 ANSWER: #{part_1_answer}"

  part_2_answer = rotator.num_zero_clicks

  puts "PART 2 ANSWER: #{part_2_answer}"
end

INPUT_FILE = './input.txt'

solve(INPUT_FILE)
