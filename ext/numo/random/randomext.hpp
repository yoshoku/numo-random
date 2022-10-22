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
#include <type_traits>
#include <typeinfo>

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
    rb_define_method(rb_cPCG64, "cauchy", RUBY_METHOD_FUNC(_numo_random_pcg64_cauchy), -1);
    rb_define_method(rb_cPCG64, "chisquare", RUBY_METHOD_FUNC(_numo_random_pcg64_chisquare), -1);
    rb_define_method(rb_cPCG64, "f", RUBY_METHOD_FUNC(_numo_random_pcg64_f), -1);
    rb_define_method(rb_cPCG64, "normal", RUBY_METHOD_FUNC(_numo_random_pcg64_normal), -1);
    rb_define_method(rb_cPCG64, "lognormal", RUBY_METHOD_FUNC(_numo_random_pcg64_lognormal), -1);
    rb_define_method(rb_cPCG64, "standard_t", RUBY_METHOD_FUNC(_numo_random_pcg64_standard_t), -1);
    return rb_cPCG64;
  }

private:
  static const rb_data_type_t pcg64_type;

  // #initialize

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

  // #seed=

  static VALUE _numo_random_pcg64_set_seed(VALUE self, VALUE seed) {
    get_pcg64(self)->seed(NUM2LONG(seed));
    rb_iv_set(self, "seed", seed);
    return Qnil;
  }

  // #seed

  static VALUE _numo_random_pcg64_get_seed(VALUE self) {
    return rb_iv_get(self, "seed");
  }

  // #random

  static VALUE _numo_random_pcg64_random(VALUE self) {
    std::uniform_real_distribution<double> uniform_dist(0, 1);
    pcg64* ptr = get_pcg64(self);
    const double x = uniform_dist(*ptr);
    return DBL2NUM(x);
  }

  // -- common subroutine --

  template<class D> struct rand_opt_t {
    D dist;
    pcg64* rnd;
  };

  template<class D, typename T> static void _iter_rand(na_loop_t* const lp) {
    rand_opt_t<D>* opt = (rand_opt_t<D>*)(lp->opt_ptr);

    size_t i;
    char* p1;
    ssize_t s1;
    size_t* idx1;
    INIT_COUNTER(lp, i);
    INIT_PTR_IDX(lp, 0, p1, s1, idx1);

    if (idx1) {
      for (; i--;) {
        SET_DATA_INDEX(p1, idx1, T, opt->dist(*(opt->rnd)));
      }
    } else {
      for (; i--;) {
        SET_DATA_STRIDE(p1, s1, T, opt->dist(*(opt->rnd)));
      }
    }
  }

  // #cauchy

  template<typename T> static VALUE _rand_cauchy(VALUE& self, VALUE& x, const double& loc, const double& scale) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::cauchy_distribution<T> cauchy_dist(loc, scale);
    ndfunc_t ndf = { _iter_rand<std::cauchy_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::cauchy_distribution<T>> opt = { cauchy_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
  }

  static VALUE _numo_random_pcg64_cauchy(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("loc"), rb_intern("scale") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 2, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double loc = kw_values[0] == Qundef ? 0.0 : NUM2DBL(kw_values[0]);
    const double scale = kw_values[1] == Qundef ? 1.0 : NUM2DBL(kw_values[1]);
    if (scale < 0) rb_raise(rb_eArgError, "scale must be a non-negative value");

    return klass == numo_cSFloat ? _rand_cauchy<float>(self, x, loc, scale) : _rand_cauchy<double>(self, x, loc, scale);
  }

  // #chisqure

  template<typename T> static VALUE _rand_chisquare(VALUE& self, VALUE& x, const double& df) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::chi_squared_distribution<T> chisquare_dist(df);
    ndfunc_t ndf = { _iter_rand<std::chi_squared_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::chi_squared_distribution<T>> opt = { chisquare_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
  }

  static VALUE _numo_random_pcg64_chisquare(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[1] = { rb_intern("df") };
    VALUE kw_values[1] = { Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 1, 0, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double df = NUM2DBL(kw_values[0]);
    if (df <= 0) rb_raise(rb_eArgError, "df must be > 0");

    return klass == numo_cSFloat ? _rand_chisquare<float>(self, x, df) : _rand_chisquare<double>(self, x, df);
  }

  // #f

  template<typename T> static VALUE _rand_f(VALUE& self, VALUE& x, const double& dfnum, const double& dfden) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::fisher_f_distribution<T> f_dist(dfnum, dfden);
    ndfunc_t ndf = { _iter_rand<std::fisher_f_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::fisher_f_distribution<T>> opt = { f_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
  }

  static VALUE _numo_random_pcg64_f(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("dfnum"), rb_intern("dfden") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 2, 0, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double dfnum = NUM2DBL(kw_values[0]);
    const double dfden = NUM2DBL(kw_values[1]);
    if (dfnum <= 0) rb_raise(rb_eArgError, "dfnum must be > 0");
    if (dfden <= 0) rb_raise(rb_eArgError, "dfden must be > 0");

    return klass == numo_cSFloat ? _rand_f<float>(self, x, dfnum, dfden) : _rand_f<double>(self, x, dfnum, dfden);
  }

  // #normal

  template<typename T> static VALUE _rand_normal(VALUE& self, VALUE& x, const double& loc, const double& scale) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::normal_distribution<T> normal_dist(loc, scale);
    ndfunc_t ndf = { _iter_rand<std::normal_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::normal_distribution<T>> opt = { normal_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
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

    const double loc = kw_values[0] == Qundef ? 0.0 : NUM2DBL(kw_values[0]);
    const double scale = kw_values[1] == Qundef ? 1.0 : NUM2DBL(kw_values[1]);
    if (scale < 0) rb_raise(rb_eArgError, "scale must be a non-negative value");

    return klass == numo_cSFloat ? _rand_normal<float>(self, x, loc, scale) : _rand_normal<double>(self, x, loc, scale);
  }

  // #lognormal

  template<typename T> static VALUE _rand_lognormal(VALUE& self, VALUE& x, const double& mean, const double& sigma) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::lognormal_distribution<T> lognormal_dist(mean, sigma);
    ndfunc_t ndf = { _iter_rand<std::lognormal_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::lognormal_distribution<T>> opt = { lognormal_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
  }

  static VALUE _numo_random_pcg64_lognormal(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("mean"), rb_intern("sigma") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 2, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double mean = kw_values[0] == Qundef ? 0.0 : NUM2DBL(kw_values[0]);
    const double sigma = kw_values[1] == Qundef ? 1.0 : NUM2DBL(kw_values[1]);
    if (sigma < 0) rb_raise(rb_eArgError, "sigma must be a non-negative value");

    return klass == numo_cSFloat ? _rand_lognormal<float>(self, x, mean, sigma) : _rand_lognormal<double>(self, x, mean, sigma);
  }

  // #standard_t

  template<typename T> static VALUE _rand_t(VALUE& self, VALUE& x, const double& df) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::student_t_distribution<T> t_dist(df);
    ndfunc_t ndf = { _iter_rand<std::student_t_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::student_t_distribution<T>> opt = { t_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
    return x;
  }

  static VALUE _numo_random_pcg64_standard_t(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[1] = { rb_intern("df") };
    VALUE kw_values[1] = { Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 1, 0, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double df = NUM2DBL(kw_values[0]);
    if (df <= 0) rb_raise(rb_eArgError, "df must be > 0");

    return klass == numo_cSFloat ? _rand_t<float>(self, x, df) : _rand_t<double>(self, x, df);
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
