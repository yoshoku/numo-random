/**
 * Numo::Random provides random number generation with several distributions for Numo::NArray.
 *
 * Copyright (c) 2022 Atsushi Tatsuma
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

#ifndef NUMO_RANDOMEXT_HPP
#define NUMO_RANDOMEXT_HPP 1

#include <ruby.h>

#include <numo/narray.h>
#include <numo/template.h>

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
    rb_define_method(rb_cPCG64, "poisson", RUBY_METHOD_FUNC(_numo_random_pcg64_poisson), -1);
    rb_define_method(rb_cPCG64, "discrete", RUBY_METHOD_FUNC(_numo_random_pcg64_discrete), -1);
    rb_define_method(rb_cPCG64, "uniform", RUBY_METHOD_FUNC(_numo_random_pcg64_uniform), -1);
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
    if (kw_values[0] == Qundef || NIL_P(kw_values[0])) {
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

  // #poisson

  template<typename T> static void _rand_poisson(VALUE& self, VALUE& x, const double& mean) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::poisson_distribution<T> poisson_dist(mean);
    ndfunc_t ndf = { _iter_rand<std::poisson_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::poisson_distribution<T>> opt = { poisson_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
  }

  static VALUE _numo_random_pcg64_poisson(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("mean") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 1, kw_values);

    const VALUE klass = rb_obj_class(x);
    if (klass != numo_cInt8 && klass != numo_cInt16 && klass != numo_cInt32 && klass != numo_cInt64
        && klass != numo_cUInt8 && klass != numo_cUInt16 && klass != numo_cUInt32 && klass != numo_cUInt64)
      rb_raise(rb_eTypeError, "invalid NArray class, it must be integer typed array");

    const double mean = kw_values[0] == Qundef ? 0.0 : NUM2DBL(kw_values[0]);
    if (mean <= 0.0) rb_raise(rb_eArgError, "mean must be > 0");

    if (klass == numo_cInt8) {
      _rand_poisson<int8_t>(self, x, mean);
    } else if (klass == numo_cInt16) {
      _rand_poisson<int16_t>(self, x, mean);
    } else if (klass == numo_cInt32) {
      _rand_poisson<int32_t>(self, x, mean);
    } else if (klass == numo_cInt64) {
      _rand_poisson<int64_t>(self, x, mean);
    } else if (klass == numo_cUInt8) {
      _rand_poisson<uint8_t>(self, x, mean);
    } else if (klass == numo_cUInt16) {
      _rand_poisson<uint16_t>(self, x, mean);
    } else if (klass == numo_cUInt32) {
      _rand_poisson<uint32_t>(self, x, mean);
    } else if (klass == numo_cUInt64) {
      _rand_poisson<uint64_t>(self, x, mean);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #discrete

  template<typename T, typename P> static void _rand_discrete(VALUE& self, VALUE& x, const std::vector<P>& weight) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::discrete_distribution<T> discrete_dist(weight.begin(), weight.end());
    ndfunc_t ndf = { _iter_rand<std::discrete_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::discrete_distribution<T>> opt = { discrete_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
  }

  static VALUE _numo_random_pcg64_discrete(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[1] = { rb_intern("weight") };
    VALUE kw_values[1] = { Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 1, 0, kw_values);

    VALUE klass = rb_obj_class(x);
    if (klass != numo_cInt8 && klass != numo_cInt16 && klass != numo_cInt32 && klass != numo_cInt64
        && klass != numo_cUInt8 && klass != numo_cUInt16 && klass != numo_cUInt32 && klass != numo_cUInt64)
      rb_raise(rb_eTypeError, "invalid NArray class, it must be integer typed array");

    VALUE w = kw_values[0];
    VALUE w_klass = rb_obj_class(w);
    if (w_klass != numo_cSFloat && w_klass != numo_cDFloat) rb_raise(rb_eTypeError, "weight must be Numo::DFloat or Numo::SFloat");

    if (!RTEST(nary_check_contiguous(w))) w = nary_dup(w);
    narray_t* w_nary;
    GetNArray(w, w_nary);
    if (NA_NDIM(w_nary) != 1) rb_raise(rb_eArgError, "weight must be 1-dimensional array");

    const size_t w_len = NA_SHAPE(w_nary)[0];
    if (w_len < 1) rb_raise(rb_eArgError, "length of weight must be > 0");

    if (w_klass == numo_cSFloat) {
      const float* w_ptr = (float*)na_get_pointer_for_read(w);
      std::vector<float> w_vec(w_ptr, w_ptr + w_len);
      if (klass == numo_cInt8) {
        _rand_discrete<int8_t, float>(self, x, w_vec);
      } else if (klass == numo_cInt16) {
        _rand_discrete<int16_t, float>(self, x, w_vec);
      } else if (klass == numo_cInt32) {
        _rand_discrete<int32_t, float>(self, x, w_vec);
      } else if (klass == numo_cInt64) {
        _rand_discrete<int64_t, float>(self, x, w_vec);
      } else if (klass == numo_cUInt8) {
        _rand_discrete<uint8_t, float>(self, x, w_vec);
      } else if (klass == numo_cUInt16) {
        _rand_discrete<uint16_t, float>(self, x, w_vec);
      } else if (klass == numo_cUInt32) {
        _rand_discrete<uint32_t, float>(self, x, w_vec);
      } else if (klass == numo_cUInt64) {
        _rand_discrete<uint64_t, float>(self, x, w_vec);
      }
    } else {
      const double* w_ptr = (double*)na_get_pointer_for_read(w);
      std::vector<double> w_vec(w_ptr, w_ptr + w_len);
      if (klass == numo_cInt8) {
        _rand_discrete<int8_t, double>(self, x, w_vec);
      } else if (klass == numo_cInt16) {
        _rand_discrete<int16_t, double>(self, x, w_vec);
      } else if (klass == numo_cInt32) {
        _rand_discrete<int32_t, double>(self, x, w_vec);
      } else if (klass == numo_cInt64) {
        _rand_discrete<int64_t, double>(self, x, w_vec);
      } else if (klass == numo_cUInt8) {
        _rand_discrete<uint8_t, double>(self, x, w_vec);
      } else if (klass == numo_cUInt16) {
        _rand_discrete<uint16_t, double>(self, x, w_vec);
      } else if (klass == numo_cUInt32) {
        _rand_discrete<uint32_t, double>(self, x, w_vec);
      } else if (klass == numo_cUInt64) {
        _rand_discrete<uint64_t, double>(self, x, w_vec);
      }
    }

    RB_GC_GUARD(w);
    RB_GC_GUARD(x);
    return Qnil;
  }

  // #uniform

  template<typename T> static void _rand_uniform(VALUE& self, VALUE& x, const double& low, const double& high) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::uniform_real_distribution<T> uniform_dist(low, high);
    ndfunc_t ndf = { _iter_rand<std::uniform_real_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::uniform_real_distribution<T>> opt = { uniform_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
  }

  static VALUE _numo_random_pcg64_uniform(int argc, VALUE* argv, VALUE self) {
    VALUE x = Qnil;
    VALUE kw_args = Qnil;
    ID kw_table[2] = { rb_intern("low"), rb_intern("high") };
    VALUE kw_values[2] = { Qundef, Qundef };
    rb_scan_args(argc, argv, "1:", &x, &kw_args);
    rb_get_kwargs(kw_args, kw_table, 0, 2, kw_values);

    VALUE klass = rb_obj_class(x);
    if (klass != numo_cSFloat && klass != numo_cDFloat) rb_raise(rb_eTypeError, "invalid NArray class, it must be DFloat or SFloat");

    const double low = kw_values[0] == Qundef ? 0.0 : NUM2DBL(kw_values[0]);
    const double high = kw_values[1] == Qundef ? 1.0 : NUM2DBL(kw_values[1]);
    if (high - low < 0) rb_raise(rb_eArgError, "high - low must be > 0");

    if (klass == numo_cSFloat) {
      _rand_uniform<float>(self, x, low, high);
    } else {
      _rand_uniform<double>(self, x, low, high);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #cauchy

  template<typename T> static void _rand_cauchy(VALUE& self, VALUE& x, const double& loc, const double& scale) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::cauchy_distribution<T> cauchy_dist(loc, scale);
    ndfunc_t ndf = { _iter_rand<std::cauchy_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::cauchy_distribution<T>> opt = { cauchy_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_cauchy<float>(self, x, loc, scale);
    } else {
      _rand_cauchy<double>(self, x, loc, scale);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #chisqure

  template<typename T> static void _rand_chisquare(VALUE& self, VALUE& x, const double& df) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::chi_squared_distribution<T> chisquare_dist(df);
    ndfunc_t ndf = { _iter_rand<std::chi_squared_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::chi_squared_distribution<T>> opt = { chisquare_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_chisquare<float>(self, x, df);
    } else {
      _rand_chisquare<double>(self, x, df);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #f

  template<typename T> static void _rand_f(VALUE& self, VALUE& x, const double& dfnum, const double& dfden) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::fisher_f_distribution<T> f_dist(dfnum, dfden);
    ndfunc_t ndf = { _iter_rand<std::fisher_f_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::fisher_f_distribution<T>> opt = { f_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_f<float>(self, x, dfnum, dfden);
    } else {
      _rand_f<double>(self, x, dfnum, dfden);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #normal

  template<typename T> static void _rand_normal(VALUE& self, VALUE& x, const double& loc, const double& scale) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::normal_distribution<T> normal_dist(loc, scale);
    ndfunc_t ndf = { _iter_rand<std::normal_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::normal_distribution<T>> opt = { normal_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_normal<float>(self, x, loc, scale);
    } else {
      _rand_normal<double>(self, x, loc, scale);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #lognormal

  template<typename T> static void _rand_lognormal(VALUE& self, VALUE& x, const double& mean, const double& sigma) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::lognormal_distribution<T> lognormal_dist(mean, sigma);
    ndfunc_t ndf = { _iter_rand<std::lognormal_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::lognormal_distribution<T>> opt = { lognormal_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_lognormal<float>(self, x, mean, sigma);
    } else {
      _rand_lognormal<double>(self, x, mean, sigma);
    }

    RB_GC_GUARD(x);
    return Qnil;
  }

  // #standard_t

  template<typename T> static void _rand_t(VALUE& self, VALUE& x, const double& df) {
    pcg64* ptr = get_pcg64(self);
    ndfunc_arg_in_t ain[1] = { { OVERWRITE, 0 } };
    std::student_t_distribution<T> t_dist(df);
    ndfunc_t ndf = { _iter_rand<std::student_t_distribution<T>, T>, FULL_LOOP, 1, 0, ain, 0 };
    rand_opt_t<std::student_t_distribution<T>> opt = { t_dist, ptr };
    na_ndloop3(&ndf, &opt, 1, x);
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

    if (klass == numo_cSFloat) {
      _rand_t<float>(self, x, df);
    } else {
      _rand_t<double>(self, x, df);
    }

    RB_GC_GUARD(x);
    return Qnil;
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
