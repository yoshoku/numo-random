/**
 * Numo::Random provides random number generation with several distributions for Numo::NArray.
 *
 * Copyright (c) 2022-2025 Atsushi Tatsuma
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "ext.hpp"

extern "C" void Init_ext(void) {
  rb_require("numo/narray");

  VALUE rb_mNumoRandom = rb_define_module_under(mNumo, "Random");
  RbNumoRandomPCG32::define_class(rb_mNumoRandom, "PCG32");
  RbNumoRandomPCG64::define_class(rb_mNumoRandom, "PCG64");
  RbNumoRandomMT32::define_class(rb_mNumoRandom, "MT32");
  RbNumoRandomMT64::define_class(rb_mNumoRandom, "MT64");
}
