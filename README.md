# SmartEnum

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
  extend SmartEnum

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
  extend SmartEnum

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
  extend SmartEnum

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
  extend SmartEnum

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
  extend SmartEnum

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
#         3: from .../smart_enum/lib/smart_enum.rb:35:in `variant'
#         2: from .../smart_enum/lib/smart_enum.rb:49:in `ensure_all_methods_defined_for_each_variant!'
#         1: from .../smart_enum/lib/smart_enum.rb:49:in `each'
# .../smart_enum/lib/smart_enum.rb:54:in `block in ensure_all_methods_defined_for_each_variant!': Variant Blue is missing the following methods: (SmartEnum::MissingMethods)
#   rgb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tonsser/smart_enum
