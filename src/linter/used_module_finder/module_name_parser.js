import _ from 'lodash';
import builtIns from 'builtin-modules';

const globalExecutables = ['npm'];

export default {
  isBuiltIn(name) {
    return builtIns.includes(name);
  },

  isGlobalExecutable(name) {
    return globalExecutables.includes(name);
  },

  isRelative(name) {
    return name[0] === '.';
  },

  stripLoaders(name) {
    let array = name.split('!');
    return _.last(array);
  },

  stripSubpath(name) {
    const parts = name.split('/');
    if (name[0] === '@') {
      return parts.slice(0, 2).join('/');
    } else {
      return parts[0];
    }
  },
};
