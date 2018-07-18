module SmartEnum
  class Matcher
    def initialize(all_variants:)
      @cases = []
      @all_variants = all_variants
    end

    def on(a_case, &block)
      cases << [a_case, block]
    end

    def match_on(variant)
      ensure_all_variants_handled!

      match = cases.detect do |a_case, _block|
        a_case === variant
      end

      if match
        match.last.call
      end
    end

    private

    attr_reader :cases, :all_variants

    def ensure_all_variants_handled!
      variants_handled = cases.map(&:first)

      all_variants.each do |name, variant|
        next if variants_handled.include?(variant)
        raise NonExhaustiveMatch, <<~EOS
          Variant #{name} is not handled
        EOS
      end
    end

    class NonExhaustiveMatch < StandardError; end
  end
end
