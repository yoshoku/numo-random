# Numo::Random

[![Build Status](https://github.com/yoshoku/numo-random/actions/workflows/main.yml/badge.svg)](https://github.com/yoshoku/numo-random/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/numo-random.svg)](https://badge.fury.io/rb/numo-random)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellowgreen.svg)](https://github.com/yoshoku/numo-random/blob/main/LICENSE.txt)
[![Documentation](https://img.shields.io/badge/api-reference-blue.svg)](https://gemdocs.org/gems/numo-random/)

Numo::Random provides random number generation with several distributions for Numo::NArray.

Note: Since v0.6.0, this gem uses [Numo::NArray Alternative](https://github.com/yoshoku/numo-narray-alt) instead of Numo::NArray as a dependency.

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

# Creating random number generator.
rng = Numo::Random::Generator.new(seed: 42)

# Generating random numbers with a normal distribution.
x = rng.normal(shape: [5000, 2], loc: 0.0, scale: 1.0)

# Plotting the generated result.
Numo.gnuplot do
  set(terminal: 'png')
  set(output: 'normal2d.png')
  plot(x[true, 0], x[true, 1])
end
```

![normal2d.png](https://user-images.githubusercontent.com/5562409/197376738-ee8d2b12-1902-4a12-bcf3-757461f2f2db.png)


An example of generating random numbers according to the Poisson distribution:

```ruby
require 'numo/narray'
require 'numo/gnuplot'

require 'numo/random'

# Creating random number generator.
rng = Numo::Random::Generator.new(seed: 9)

# Generating random numbers with Poisson distribution.
x = rng.poisson(shape: 10000, mean: 12)

# Plotting the generated result.
h = x.bincount

Numo.gnuplot do
  set(terminal: 'png')
  set(output: 'poisson2d.png')
  plot(h, with: 'boxes')
end
```

![poisson2d.png](https://user-images.githubusercontent.com/5562409/201478863-61d31eb8-7c0b-4406-b255-fff29187a16a.png)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/numo-random.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [code of conduct](https://github.com/yoshoku/numo-random/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache-2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
