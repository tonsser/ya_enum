require "test_helper"

class SmartEnumTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SmartEnum::VERSION
  end

  def test_basic_interface
    colors = Module.new do
      extend SmartEnum

      variant :Red do
        def rgb_values
          { red: 255, green: 0, blue: 0 }
        end
      end

      variant :Blue do
        def rgb_values
          { red: 0, green: 0, blue: 255 }
        end
      end
    end

    assert colors::Red == colors::Red
    assert colors::Blue == colors::Blue

    refute colors::Red == colors::Blue
    refute colors::Blue == colors::Red

    assert_equal ({ red: 255, green: 0, blue: 0 }), colors::Red.rgb_values
  end

  def test_associated_values
    deep_links = Module.new do
      extend SmartEnum

      variant :User, [:user] do
        def url
          "/users/#{user.id}"
        end
      end
    end

    user = Class.new do
      def id
        1
      end
    end.new

    assert_equal "/users/#{user.id}", deep_links::User.new(user: user).url
  end

  def test_missing_implementation_of_method_for_variant
    assert_raises(SmartEnum::MissingMethods) do
      Module.new do
        extend SmartEnum

        variant :Red do
          def rgb_values
            { red: 255, green: 0, blue: 0 }
          end
        end

        variant :Blue do
          def hex_value
            "#0000FF"
          end
        end
      end
    end
  end

  def test_missing_implementation_of_method_for_variant_with_associated_value
    assert_raises(SmartEnum::MissingMethods) do
      Module.new do
        extend SmartEnum

        variant :User, [:user] do
          def url
            "/users/#{user.id}"
          end
        end

        variant :Team, [:team]
      end
    end
  end

  def test_variants_work_in_case_statements
    colors = Module.new do
      extend SmartEnum

      variant :Red
      variant :Blue
    end

    color = colors::Red
    value = nil

    case color
    when colors::Red
      value = :ok
    when colors::Blue
      value = :err
    else
      raise "Nothing matched"
    end

    assert_equal :ok, value
  end

  def test_variants_work_in_case_statements_with_associated_values
    deep_links = Module.new do
      extend SmartEnum

      variant :User, [:user]
      variant :Team, [:team]
    end

    deep_link = deep_links::User.new(user: Object.new)
    value = nil

    case deep_link
    when deep_links::User
      value = :ok
    when deep_links::Team
      value = :err
    else
      raise "Nothing matched"
    end

    assert_equal :ok, value
  end

  def test_inheriting_methods
    colors = Module.new do
      extend SmartEnum

      variant :Red do
        def rgb_values
          { red: max, green: 0, blue: 0 }
        end

        def max_on_variant
          255
        end
      end

      def max
        max_on_variant
      end
    end

    assert_equal ({ red: 255, green: 0, blue: 0 }), colors::Red.rgb_values
    assert_equal 255, colors::Red.max
  end

  def test_inheriting_methods_with_associated_values
    colors = Module.new do
      extend SmartEnum

      variant :Red, [:value] do
        def rgb_values
          { red: max, green: 0, blue: 0 }
        end

        def max_on_variant
          255
        end
      end

      def max
        max_on_variant
      end
    end

    assert_equal ({ red: 255, green: 0, blue: 0 }), colors::Red.new(value: nil).rgb_values
    assert_equal 255, colors::Red.new(value: nil).max
  end

  def test_matching
    colors = Module.new do
      extend SmartEnum

      variant :Red
      variant :Blue
    end

    color = colors::Red

    result = colors.case color do
      on colors::Red do
        :ok
      end

      on colors::Blue do
        :err
      end
    end

    assert_equal :ok, result
  end

  def test_matching_with_associated_values
    colors = Module.new do
      extend SmartEnum

      variant :Red, [:value]
      variant :Blue, [:value]
    end

    color = colors::Red.new(value: 123)

    result = colors.case color do
      on colors::Red do
        :ok
      end

      on colors::Blue do
        :err
      end
    end

    assert_equal :ok, result
  end

  def test_no_match_raises
    colors = Module.new do
      extend SmartEnum

      variant :Red
      variant :Blue
    end

    result = colors.case nil do
      on colors::Red do
        :ok
      end

      on colors::Blue do
        :err
      end
    end

    assert_nil result
  end

  def test_matches_are_exhaustive
    colors = Module.new do
      extend SmartEnum

      variant :Red
      variant :Blue
    end

    color = colors::Red

    assert_raises(SmartEnum::Matcher::NonExhaustiveMatch) do
      colors.case color do
        on colors::Red do
          :ok
        end
      end
    end
  end
end
