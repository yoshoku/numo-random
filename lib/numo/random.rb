# frozen_string_literal: true

require 'numo/narray/alt'

require_relative 'random/version'
# On distributions like Rocky Linux, native extensions are installed in a separate
# directory from Ruby code, so use require to load them.
require 'numo/random/ext'
require_relative 'random/generator'
