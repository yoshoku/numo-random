# frozen_string_literal: true

RSpec.describe Numo::Random do
  it 'has a version number' do
    expect(Numo::Random::VERSION).not_to be_nil
  end

  it 'sets and gets random seed', :aggregate_failures do
    rng = Numo::Random::PCG64.new(seed: 10)
    expect(rng.seed).to eq(10)
    rng.seed = 100
    expect(rng.seed).to eq(100)
  end

  it 'gets random number' do
    rng = Numo::Random::PCG64.new
    expect(rng.random).not_to be_nil
  end
end
