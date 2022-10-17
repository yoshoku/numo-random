/**
 * Copyright (c) 2022 Atsushi Tatsuma
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef NUMO_RANDOMEXT_HPP
#define NUMO_RANDOMEXT_HPP 1

#include <ruby.h>

#include <numo/narray.h>
#include <numo/template.h>

#include <iostream>
#include <random>

#include <pcg_random.hpp>

class RbNumoRandomPCG64 {
public:
  static VALUE numo_random_pcg64_alloc(VALUE self) {
    pcg64* ptr = (pcg64*)ruby_xmalloc(sizeof(pcg64));
    new (ptr) pcg64();
    return TypedData_Wrap_Struct(self, &pcg64_type, ptr);
  }

  static void numo_random_pcg64_free(void* ptr) {
    ((pcg64*)ptr)->~pcg64();
    ruby_xfree(ptr);
  }

  static size_t numo_random_pcg64_size(const void* ptr) {
    return sizeof(*((pcg64*)ptr));
  }

  static pcg64* get_pcg64(VALUE self) {
    pcg64* ptr;
    TypedData_Get_Struct(self, pcg64, &pcg64_type, ptr);
    return ptr;
  }

  static VALUE define_class(VALUE rb_mNumoRandom) {
    VALUE rb_cPCG64 = rb_define_class_under(rb_mNumoRandom, "PCG64", rb_cObject);
    rb_define_alloc_func(rb_cPCG64, numo_random_pcg64_alloc);
    rb_define_method(rb_cPCG64, "initialize", RUBY_METHOD_FUNC(_numo_random_pcg64_init), -1);
    rb_define_method(rb_cPCG64, "seed=", RUBY_METHOD_FUNC(_numo_random_pcg64_set_seed), 1);
    rb_define_method(rb_cPCG64, "seed", RUBY_METHOD_FUNC(_numo_random_pcg64_get_seed), 0);
    rb_define_method(rb_cPCG64, "random", RUBY_METHOD_FUNC(_numo_random_pcg64_random), 0);
    rb_define_method(rb_cPCG64, "normal", RUBY_METHOD_FUNC(_numo_random_pcg64_normal), -1);
    return rb_cPCG64;
  }

private:
  static const rb_data_type_t pcg64_type;

  static VALUE _numo_random_pcg64_init(int argc, VALUE* argv, VALUE self) {
    VALUE kw_args = Qnil;
    ID kw_table[1] = { rb_intern("seed") };
    VALUE kw_values[1] = { Qundef };
    rb_scan_args(argc, argv, ":", &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 1, kw_values);
    pcg64* ptr = get_pcg64(self);
    if (kw_values[0] == Qundef) {
      std::random_device rd;
      const unsigned int seed = rd();
      new (ptr) pcg64(seed);
      rb_iv_set(self, "seed", UINT2NUM(seed));
    } else {
      new (ptr) pcg64(NUM2LONG(kw_values[0]));
      rb_iv_set(self, "seed", kw_values[0]);
    }
    return Qnil;
  }

  static VALUE _numo_random_pcg64_set_seed(VALUE self, VALUE seed) {
    get_pcg64(self)->seed(NUM2LONG(seed));
    rb_iv_set(self, "seed", seed);
    return Qnil;
  }

  static VALUE _numo_random_pcg64_get_seed(VALUE self) {
    return rb_iv_get(self, "seed");
  }

  static VALUE _numo_random_pcg64_random(VALUE self) {
    std::uniform_real_distribution<double> uniform_dist(0, 1);
    pcg64* ptr = get_pcg64(self);
    const double x = uniform_dist(*ptr);
    return DBL2NUM(x);
  }

  typedef struct {
    double loc;
    double scale;
    pcg64* rnd;
  } normal_opt_t;

  template<typename T> static void iter_normal(na_loop_t* const lp) {
    normal_opt_t* g = (normal_opt_t*)(lp->opt_ptr);
    std::normal_distribution<T> normal_dist(g->loc, g->scale);

    size_t i;
    char* p1;
    ssize_t s1;
    size_t* idx1;
    INIT_COUNTER(lp, i);
    INIT_PTR_IDX(lp, 0, p1, s1, idx1);

    if (idx1) {
      for (; i--;) {
        SET_DATA_INDEX(p1, idx1, T, normal_dist(*(g->rnd)));
      }
    } else {
      for (; i--;) {
        SET_DATA_STRIDE(p1, s1, T, normal_dist(*(g->rnd)));
      }
    }
  }

  static VALUE _numo_random_pcg64_normal(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("loc"), rb_intern("scale") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 2, kw_values);

    VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    pcg64* ptr = get_pcg64(self);
    normal_opt_t g = { 0.0, 1.0, ptr };
    if (kw_values[0] != Qundef) g.loc = NUM2DBL(kw_values[0]);
    if (kw_values[1] != Qundef) g.scale = NUM2DBL(kw_values[1]);
    if (g.scale < 0) rb_raise(rb_eArgError, "scale must be a non-negative value");

    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    ndfunc_t ndf = { klass == numo_cSFloat ? iter_normal<float> : iter_normal<double>, FULL_LOOP, 1, 0, ain, 0 };

    na_ndloop3(&ndf, &g, 1, x);

    return x;
  }
};

const rb_data_type_t RbNumoRandomPCG64::pcg64_type = {
  "RbNumoRandomPCG64",
  {
    NULL,
    RbNumoRandomPCG64::numo_random_pcg64_free,
    RbNumoRandomPCG64::numo_random_pcg64_size
  },
  NULL,
  NULL,
  RUBY_TYPED_FREE_IMMEDIATELY
};

#endif /* NUMO_RANDOMEXT_HPP */
