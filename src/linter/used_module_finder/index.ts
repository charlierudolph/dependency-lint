import _ from 'lodash';
import ExecutedModuleFinder from './executed_module_finder';
import Promise from 'bluebird';
import RequiredModuleFinder from './required_module_finder';

export default class UsedModuleFinder {
  constructor(config) {
    this.executedModuleFinder = new ExecutedModuleFinder(
      config.executedModules
    );
    this.requiredModuleFinder = new RequiredModuleFinder(
      config.requiredModules
    );
  }

  async find({ dir, packageJson }) {
    return this.normalizeModules(
      await Promise.all([
        this.executedModuleFinder.find({ dir, packageJson }),
        this.requiredModuleFinder.find(dir),
      ])
    );
  }

  normalizeModules(...modules) {
    const result = {};
    for (const { name, file, script } of _.flattenDeep(modules)) {
      if (!result[name]) {
        result[name] = { name, files: [], scripts: [] };
      }
      if (file) {
        result[name].files.push(file);
      }
      if (script) {
        result[name].scripts.push(script);
      }
    }
    return _.values(result);
  }
}
