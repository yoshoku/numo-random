# Numo::Random

Numo::Random provides random number generation with several distributions for Numo::NArray.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'numo-random'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install numo-random

## Usage

An example of generating random numbers according to the standard normal distribution:

```ruby
require 'numo/narray'
require 'numo/gnuplot'

require 'numo/random'

# Prepareing array to be filled with random numbers.
x = Numo::DFloat.new(5000, 2)

# Creating random number generator.
rng = Numo::Random::Generator.new(seed: 42)

# Generating random numbers with a normal distribution.
rng.normal(x, loc: 0.0, scale: 1.0)

# Plotting the generated result.
Numo.gnuplot do
  set(terminal: 'png')
  set(output: 'normal2d.png')
  plot(x[true, 0], x[true, 1])
end
```

![normal2d.png](https://user-images.githubusercontent.com/5562409/197376738-ee8d2b12-1902-4a12-bcf3-757461f2f2db.png)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/numo-random.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [code of conduct](https://github.com/yoshoku/numo-random/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
