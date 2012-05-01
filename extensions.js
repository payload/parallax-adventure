// Generated by CoffeeScript 1.3.1
(function() {
  var __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function() {
    this.P = function() {
      var x, xs, _i;
      xs = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), x = arguments[_i++];
      console.log.apply(console, __slice.call(xs).concat([x]));
      return x;
    };
    this.OBJ_X = function() {
      var k, o, v, x, xs, _i, _len;
      o = arguments[0], xs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        for (k in x) {
          v = x[k];
          o[k] = v;
        }
      }
      return o;
    };
    this.OBJ_RX = function() {
      var k, ks, o, v, x, xs, _i, _len;
      o = arguments[0], xs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      ks = Object.keys(o);
      for (_i = 0, _len = xs.length; _i < _len; _i++) {
        x = xs[_i];
        for (k in x) {
          v = x[k];
          if (__indexOf.call(ks, k) >= 0) {
            o[k] = v;
          }
        }
      }
      return o;
    };
    this.random = function(a, b) {
      if (b == null) {
        b = 0;
      }
      return b + (a - b) * Math.random();
    };
    this.random0 = function(x) {
      return x * (2 * Math.random() - 1);
    };
    this.randomn = function(x) {
      return Math.floor(x * Math.random());
    };
    this.max = Math.max;
    this.min = Math.min;
    this.v = cp.v;
    if (this.requestAnimationFrame == null) {
      this.requestAnimationFrame = this.mozRequestAnimationFrame || this.webkitRequestAnimationFrame;
    }
    this.delay = function(time, cb) {
      if (typeof time === 'function') {
        cb = time;
        time = 0;
      }
      if (time === 0) {
        return requestAnimationFrame(cb);
      } else {
        return setTimeout((function() {
          return requestAnimationFrame(cb);
        }), time * 1000);
      }
    };
    return this.get_id = (function() {
      var next_id;
      next_id = 1;
      return function(o) {
        var _ref;
        return (_ref = o.id) != null ? _ref : o.id = next_id++;
      };
    })();
  })();

}).call(this);