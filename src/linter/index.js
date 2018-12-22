import _ from 'lodash';
import DependencyLinter from './dependency_linter';
import InstalledModuleValidater from './installed_module_validator';
import UsedModuleFinder from './used_module_finder';

export default class Linter {
  constructor(config) {
    this.dependencyLinter = new DependencyLinter(config);
    this.installedModuleValidater = new InstalledModuleValidater();
    this.usedModuleFinder = new UsedModuleFinder(config);
  }

  getListedModules(packageJson) {
    const result = {};
    ['dependencies', 'devDependencies'].forEach(
      value => (result[value] = _.keys(packageJson[value]))
    );
    return result;
  }

  async lint({ dir, packageJson }) {
    await this.installedModuleValidater.validate({ dir, packageJson });
    const usedModules = await this.usedModuleFinder.find({ dir, packageJson });
    const listedModules = this.getListedModules(packageJson);
    return this.dependencyLinter.lint({ listedModules, usedModules });
  }
}
