require 'active_record'
require 'active_record/base'

class ActiveRecord::Base

  # Allows you to conserve space by storing several boolean attributes to one
  # integer attribute.
  #
  #   class Building < ActiveRecord::Base
  #     flag_attributes(
  #       "overdriven"                => 0b00000001,
  #       "with_points"               => 0b00000010
  #     )
  #   end
  #
  # or something shorter
  #
  #   class Building < ActiveRecord::Base
  #     binary_attributes :overdriven, :with_points
  #   end
  #
  #
  #   b = Building.new
  #   b.overdriven = true
  #   b.overdriven? => true
  #   b.with_points? => false
  #   b.with_points = true
  #   b.flags => 3
  #

  def self.binary_attributes(attributes, flags_attribute = :flags)
    hash_attr = Hash.new
    attributes.each_with_index do |key, i|
      hash_attr[key] = 2 ** i
    end

    flag_attributes(hash_attr, flags_attribute)
  end

  def self.flag_attributes(attributes, flags_attribute = :flags)
    # Calculate the full mask to be able to unset bits.
    full_mask = attributes.inject(0) { |full_mask, (_, mask)| full_mask | mask }

    get_flags = flags_attribute.to_sym
    set_flags = :"#{flags_attribute}="

    attributes.each do |method_name, mask|
      get_method = :"#{method_name}?"
      set_method = :"#{method_name}="

      # Check if bit is set in mask.
      define_method(get_method) { send(get_flags) & mask == mask }
      alias_method method_name, get_method

      # Set bit value.
      define_method(set_method) do |value|
        # rails fix
        if value and not value.to_s == '0'
          # Set bit in flags. This is done using or operation:
          #
          # 0b010101 |     0b010101 |
          # 0b001000 =     0b010000 =
          # 0b011101       0b010101
          send(set_flags, send(get_flags) | mask)
        else
          # Unset bit in flags. First we invert the full mask:
          #
          # 0b111111 ^
          # 0b000100 =
          # 0b111011
          #
          # Then we clear the bit:
          #
          # 0b010101 &
          # 0b111011 =
          # 0b010001
          send(set_flags, send(get_flags) & (full_mask ^ mask))
        end
        self
      end
    end
  end

end