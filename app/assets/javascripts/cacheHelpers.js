var cached_prefix = '_cached_';

function get_cached_loader(load_function, cache_name) {
  return function () {
    if (typeof this[cache_name] === 'undefined')
      return this[cache_name] = load_function.call(this);
    else
      return this[cache_name];
  };
}

function get_cached_writer(write_function, cache_name) {
  return function (value) {
    write_function.call(this, value);
    this[cache_name] = value;
  };
}

function init_cached_properties(obj, props) {
  batch_edit_properties(props, function (name, descriptor, obj) {
    var cache_name = cached_prefix + name;
    if (typeof descriptor === 'function') {
      descriptor.get = get_cached_loader(descriptor, cache_name);
    } else if (typeof descriptor === 'object') {
      descriptor.get = get_cached_loader(descriptor.load, cache_name);

      if (descriptor.write)
        descriptor.set = get_cached_writer(descriptor.write, cache_name);
    }

    obj[cache_name] = {};

    return descriptor;
  });

  obj.delete_cache = function (property) {
    delete this[cached_prefix + property];
  };

  return props;
}