import _ from 'lodash';
import camelCase from 'camel-case';
import ERRORS from '../errors';
import minimatch from 'minimatch';
import packageJson from '../../package.json';

export default class DependencyLinter {
  constructor(config) {
    this.config = config;
    this.devFiles = _.concat(
      this.config.executedModules.shellScripts.dev,
      this.config.requiredModules.files.dev
    );
    this.ignoreErrors = {};
    for (const key in ERRORS) {
      const value = ERRORS[key];
      this.ignoreErrors[value] = this.config.ignoreErrors[camelCase(key)];
    }
  }

  // Lints the used and listed modules
  //
  // listedModules - {dependencies, devDependencies} where each is an array of module names
  // usedModules - array of {name, files, scripts}
  //
  // Returns {dependencies, devDependencies}
  //         where each is an array of {name, files, scripts, error, warning}
  lint({ listedModules, usedModules }) {
    let key;
    const out = {
      dependencies: [],
      devDependencies: [],
    };

    for (const usedModule of usedModules) {
      const status = {
        isDependency: !this.isDevDependency(usedModule),
        listedAsDependency: Array.from(listedModules.dependencies).includes(
          usedModule.name
        ),
        listedAsDevDependency: Array.from(
          listedModules.devDependencies
        ).includes(usedModule.name),
      };
      this.parseUsedModule(usedModule, status, out);
    }

    for (key in listedModules) {
      const modules = listedModules[key];
      for (var name of modules) {
        if (!_.some(usedModules, moduleData => moduleData.name === name)) {
          const listedModule = { name, files: [], scripts: [] };
          if (key !== 'devDependencies' || name !== packageJson.name) {
            listedModule.error = ERRORS.UNUSED;
          }
          out[key].push(listedModule);
        }
      }
    }

    for (key in out) {
      const results = out[key];
      results.forEach(result => {
        if (result.error && this.isErrorIgnored(result)) {
          return (result.errorIgnored = true);
        }
      });
      out[key] = _.sortBy(results, 'name');
    }

    return out;
  }

  isErrorIgnored({ error, name }) {
    return _.some(this.ignoreErrors[error], regex => name.match(regex));
  }

  isDevDependency({ files, scripts }) {
    return (
      _.every(files, this.isDevFile.bind(this)) &&
      _.every(scripts, this.isDevScript.bind(this))
    );
  }

  isDevFile(file) {
    return _.some(this.devFiles, pattern => minimatch(file, pattern));
  }

  isDevScript(script) {
    return _.some(this.config.executedModules.npmScripts.dev, regex =>
      script.match(regex)
    );
  }

  parseUsedModule(usedModule, status, result) {
    const { isDependency, listedAsDependency, listedAsDevDependency } = status;
    if (isDependency) {
      if (listedAsDependency) {
        result.dependencies.push(usedModule);
      }
      if (listedAsDevDependency) {
        result.devDependencies.push(
          _.assign({}, usedModule, { error: ERRORS.SHOULD_BE_DEPENDENCY })
        );
      }
      if (!listedAsDependency && !listedAsDevDependency) {
        return result.dependencies.push(
          _.assign({}, usedModule, { error: ERRORS.MISSING })
        );
      }
    } else {
      if (listedAsDependency) {
        result.dependencies.push(
          _.assign({}, usedModule, { error: ERRORS.SHOULD_BE_DEV_DEPENDENCY })
        );
      }
      if (listedAsDevDependency) {
        result.devDependencies.push(usedModule);
      }
      if (!listedAsDependency && !listedAsDevDependency) {
        result.devDependencies.push(
          _.assign({}, usedModule, { error: ERRORS.MISSING })
        );
      }
    }
  }
}
