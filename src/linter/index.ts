import DependencyLinter from './dependency_linter';
import InstalledModuleValidater from './installed_module_validator';
import UsedModuleFinder from './used_module_finder';

export interface LintInput {
  dir: string;
  packageJson: any;
}

export default class Linter {
  private readonly dependencyLinter: DependencyLinter;
  private readonly installedModuleValidater: InstalledModuleValidater;
  private readonly usedModuleFinder: UsedModuleFinder;

  constructor(config: any) {
    this.dependencyLinter = new DependencyLinter(config);
    this.installedModuleValidater = new InstalledModuleValidater();
    this.usedModuleFinder = new UsedModuleFinder(config);
  }

  getListedModules(packageJson: any) {
    const result: any = {};
    ['dependencies', 'devDependencies'].forEach(
      value => (result[value] = Object.keys(packageJson[value]))
    );
    return result;
  }

  async lint({ dir, packageJson }: LintInput) {
    await this.installedModuleValidater.validate({ dir, packageJson });
    const usedModules = await this.usedModuleFinder.find({ dir, packageJson });
    const listedModules = this.getListedModules(packageJson);
    return this.dependencyLinter.lint({ listedModules, usedModules });
  }
}
