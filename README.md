# YaEnum (Yet Another Enum)

**NOTE:** This gem is not stable yet. Use at your own risk.

Easily define enums in Ruby that aren't just symbols. Your enums can have associated values and methods. Imagine if Ruby had Rust's or Swift's enums.

## Installation

Since this isn't published on rubygems.org yet, you'll have to 

1. Download the repo
2. `bundle install`
3. `rake install`

## Usage

Basic API for defining enums:

```ruby
module Colors
  extend YaEnum

  variant :Red do
    def rgb
      [255, 0, 0]
    end
  end

  variant :Blue do
    def rgb
      [0, 0, 255]
    end
  end
end

p Colors::Red.rgb # => [255, 0, 0]
p Colors::Blue.rgb # => [0, 0, 255]
```

You can also define methods outside the variants, which will be inherited by each variant

```ruby
module Colors
  extend YaEnum

  variant :Red do
    def rgb
      [max, 0, 0]
    end
  end

  variant :Blue do
    def rgb
      [0, 0, max]
    end
  end

  def max
    255
  end
end

p Colors::Blue.rgb # => [0, 0, 255]
p Colors::Blue.max # 255
```

Enums can also have associated values:

```ruby
module Colors
  extend YaEnum

  variant :Red, [:max] do
    def rgb
      [max, 0, 0]
    end
  end

  variant :Blue, [:max] do
    def rgb
      [0, 0, max]
    end
  end
end

p Colors::Red.new(max: 255).rgb # => [255, 0, 0]
p Colors::Blue.new(max: 255).rgb # => [0, 0, 255]
```

Enums can also be used in `case` statements:

```ruby
module Colors
  extend YaEnum

  variant :Red, [:max]
  variant :Blue, [:max]
end

color = Colors::Red.new(max: 255)

case color
when Colors::Red
  puts "red!"
when Colors::Blue
  puts "blue!"
else
  raise "Unknown case"
end # => red!
```

If you forget to implement a method for a variant you'll get an exception:

```ruby
module Colors
  extend YaEnum

  variant :Red, [:max] do
    def rgb
      [max, 0, 0]
    end
  end

  variant :Blue, [:max] do
  end
end

# Traceback (most recent call last):
#         5: from readme.rb:3:in `<main>'
#         4: from readme.rb:12:in `<module:Colors>'
#         3: from .../ya_enum/lib/ya_enum.rb:35:in `variant'
#         2: from .../ya_enum/lib/ya_enum.rb:49:in `ensure_all_methods_defined_for_each_variant!'
#         1: from .../ya_enum/lib/ya_enum.rb:49:in `each'
# .../ya_enum/lib/ya_enum.rb:54:in `block in ensure_all_methods_defined_for_each_variant!': Variant Blue is missing the following methods: (YaEnum::MissingMethods)
#   rgb
```

You can also use the `.case` method to ensure you're handling all cases

```ruby
module Colors
  extend YaEnum

  variant :Red
  variant :Blue
end

color = Colors::Red

Colors.case(color) do
  on(Colors::Red) do
    puts "red!"
  end

  on(Colors::Blue) do
    puts "blue!"
  end
end
```

This is different from a normal `case` statement because you'll get an `YaEnum::Matcher::NonExhaustiveMatch` exception if you forget to handle a case:

```ruby
module Colors
  extend YaEnum

  variant :Red
  variant :Blue
end

color = Colors::Red

Colors.case(color) do
  on(Colors::Red) do
    puts "red!"
  end
end

# Traceback (most recent call last):
#         5: from readme.rb:12:in `<main>'
#         4: from .../ya_enum/lib/ya_enum.rb:42:in `case'
#         3: from .../ya_enum/lib/ya_enum/matcher.rb:13:in `match_on'
#         2: from .../ya_enum/lib/ya_enum/matcher.rb:31:in `ensure_all_variants_handled!'
#         1: from .../ya_enum/lib/ya_enum/matcher.rb:31:in `each'
# .../ya_enum/lib/ya_enum/matcher.rb:33:in `block in ensure_all_variants_handled!': Variant Blue is not handled (YaEnum::Matcher::NonExhaustiveMatch)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tonsser/ya_enum
