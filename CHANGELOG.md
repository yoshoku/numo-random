## [[0.6.0](https://github.com/yoshoku/numo-random/compare/v0.5.1...v0.6.0)] - 2025-10-01

**Breaking change**

- Change dependency from numo-narray to [numo-narray-alt](https://github.com/yoshoku/numo-narray-alt).

## [0.5.1]

- Fix build failure with Xcode 14 and Ruby 3.1.x.

## [0.5.0]

- Support 32-bit PCG and Mersenne Twister.

```ruby
require 'numo/random'

# specify the pseudo random number generation algorithm by setting the algorithm argument of constructor.
rng = Numo::Random::Generator.new(algorithm: 'pcg32')
rng = Numo::Random::Generator.new(algorithm: 'pcg64') # default
rng = Numo::Random::Generator.new(algorithm: 'mt32')
rng = Numo::Random::Generator.new(algorithm: 'mt64')
```

## [0.4.0]

- Add method for random number generation with bernoulli distribution: bernoulli, binomial, negative_binomial, and geometric.

## [0.3.0]

- Change native extension filename.
- Add methods for random number generation with poisson distributions: poisson, exponential, gamma, gumbel, and weibull.

## [0.2.0]

- Add discrete method.

### Breaking Changes

- Change to return array for all methods that fill array with random numbers in Generator class.

## [0.1.0]

- Initial release.
