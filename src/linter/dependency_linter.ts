import { ErrorType } from '../errors';
import minimatch from 'minimatch';
import packageJson from '../../package.json';
import { DependencyLintConfig } from '../types';

export enum DependencyType {
  DEPENDENCY = 'dependency',
  DEV_DEPENDENCY = 'devDependency'
}

export interface LintModuleResult {
  name: string;
  listedDependencyType?: DependencyType;
  files: string[];
  scripts: string[];
  error?: ErrorType;
  errorIgnored?: boolean;
}

export interface ListedModule {
  name: string;
  dependencyType: DependencyType;
}

export interface UsedModule {
  name: string;
  files: string[];
  scripts: string[];
}

export interface LintInput {
  listedModules: ListedModule[];
  usedModules: UsedModule[];
}

export default class DependencyLinter {
  private readonly config: DependencyLintConfig;
  private readonly devFiles: string[];

  constructor(config: any) {
    this.config = config;
    this.devFiles = [].concat(
      this.config.executedModules.shellScripts.dev,
      this.config.requiredModules.files.dev
    );
  }

  lint({ listedModules, usedModules }: LintInput): LintModuleResult[] {
    let key;
    const out: LintModuleResult[] = []

    for (const usedModule of usedModules) {
      const listedDependencyType = listedModules.find(x => x.name == usedModule.name)?.dependencyType;
      const error = this.getUsedModuleError(listedDependencyType, !this.isDevDependency(usedModule))
      out.push({
        ...usedModule,
        listedDependencyType,
        error
      });
    }

    listedModules.forEach(listedModule => {
      if (!usedModules.some(usedModule => usedModule.name === listedModule.name)) {
        const result: LintModuleResult = { name: listedModule.name, files: [], scripts: [] };
        if (listedModule.dependencyType !== DependencyType.DEV_DEPENDENCY || listedModule.name !== packageJson.name) {
          result.error = ErrorType.UNUSED;
        }
        out.push(result)
      }
    })

    out.forEach(result => {
      if (result.error && this.isErrorIgnored(result)) {
        result.errorIgnored = true;
      }
    })

    return out;
  }

  isErrorIgnored({ error, name }: LintModuleResult): boolean {
    return this.config.ignoreErrors[error].some((regex: string) => name.match(regex));
  }

  isDevDependency({ files, scripts }: UsedModule): boolean {
    return (
      files.every(this.isDevFile.bind(this)) &&
      scripts.every(this.isDevScript.bind(this))
    );
  }

  isDevFile(file: string): boolean {
    return this.devFiles.some(pattern => minimatch(file, pattern));
  }

  isDevScript(script: string): boolean {
    return this.config.executedModules.npmScripts.dev.some((regex: string) =>
      script.match(regex)
    );
  }

  getUsedModuleError(listedDependencyType: DependencyType, isDependency: boolean): ErrorType {
    if (listedDependencyType == null) {
      return ErrorType.MISSING
    }
    if (isDependency && listedDependencyType == DependencyType.DEV_DEPENDENCY) {
      return ErrorType.SHOULD_BE_DEPENDENCY
    }
    if (!isDependency && listedDependencyType == DependencyType.DEPENDENCY) {
      return ErrorType.SHOULD_BE_DEV_DEPENDENCY;
    }
    return null
  }
}
