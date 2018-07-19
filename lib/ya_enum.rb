require "takes_macro"
require "ya_enum/version"
require "ya_enum/matcher"

module YaEnum
  attr_accessor :variants

  def variant(name, associated_values = [], &block)
    if variants.nil?
      self.variants = []
    end

    enum = Class.new do
      extend TakesMacro
      takes associated_values.map { |value| :"#{value}!" }

      def self.===(other)
        self == other || super
      end
    end

    if block
      if associated_values.any?
        enum.class_eval(&block)
        enum.include(self)
      else
        enum.instance_eval(&block)
        enum.extend(self)
      end
    end

    const_set(name, enum)
    variants << [name.to_s, enum]
    ensure_all_methods_defined_for_each_variant!
  end

  def case(variant, &block)
    matcher = Matcher.new(all_variants: variants)
    matcher.instance_eval(&block)
    matcher.match_on(variant)
  end

  private

  def all_methods_from_all_variants
    variants.flat_map do |_name, enum|
      unique_methods_of(enum)
    end
  end

  def ensure_all_methods_defined_for_each_variant!
    all_methods = all_methods_from_all_variants

    variants.each do |name, enum|
      missing_methods = all_methods - unique_methods_of(enum)

      next if missing_methods.empty?

      raise MissingMethods, <<~EOS
        Variant #{name} is missing the following methods:
          #{missing_methods.to_a.join(", ")}
      EOS
    end
  end

  def unique_methods_of(obj)
    (
      (obj.methods - Object.methods) +
        (obj.instance_methods - Object.instance_methods) -
        takes_macro_methods
    ).uniq
  end

  def takes_macro_methods
    [:takes, :after_takes]
  end

  class MissingMethods < StandardError; end
end
