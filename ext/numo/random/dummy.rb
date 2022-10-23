# frozen_string_literal: true

module Numo
  module Random
    # PCG64 is a class that provides random number generation with several distributions using PCG-64 algorithm.
    #
    # @example
    #   require 'numo/random'
    #
    #   x = Numo::DFloat.new(100)
    #
    #   rng = Numo::Random::PCG64.new
    #   rng.normal(x)
    #
    class PCG64
      # Gets and sets the seed of random number generator.
      # @return [Integer]
      attr_accessor :seed

      # Creates a new random number generator based-on PCG-64 algorithm.
      #
      # @param seed [Integer] random seed used to initialize the random number generator.
      def initialize(seed: nil); end

      # Returns random number with uniform distribution in the half-open interval [0, 1).
      # @return [Float]
      def random; end

      # Fills given array with uniformly distributed random values in the interval [low, high).
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param low [Float] lower boundary.
      # @param high [Float] upper boundary.
      def uniform(x, low: 0.0, high: 1.0); end

      # Fills given array with random values according to the Cauchy (Lorentz) distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      def cauchy(x, loc: 0.0, scale: 1.0); end

      # Fills given array with random values according to the Chi-squared distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param df [Float] degrees of freedom, must be > 0.
      def chisquare(x, df:); end

      # Fills given array with random values according to the F-distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param dfnum [Float] degrees of freedom in numerator, must be > 0.
      # @param dfden [Float] degrees of freedom in denominator, must be > 0.
      def f(x, dfnum:, dfden:); end

      # Fills given array with random values according to a normal (Gaussian) distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param loc [Float] location parameter.
      # @param scale [Float] scale parameter.
      def normal(x, loc: 0.0, scale: 1.0); end

      # Fills given array with random values according to a log-normal distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param mean [Float] mean of normal distribution.
      # @param sigma [Float] standard deviation of normal distribution.
      def lognormal(x, mean: 0.0, sigma: 1.0); end

      # Fills given array with random values according to the Student's t-distribution.
      #
      # @param x [Numo::DFloat | Numo::SFloat] array filled with random values.
      # @param df [Float] degrees of freedom, must be > 0.
      def standard_t(x, df:); end
    end
  end
end
