import _ from 'lodash';
import { readFile, readlink } from 'fs-extra';
import ModuleNameParser from './module_name_parser';
import path from 'path';
import Promise from 'bluebird';

const glob = Promise.promisify(require('glob'));

export default class ExecutedModulesFinder {
  constructor({ shellScripts }) {
    this.findModuleExecutableUsage = this.findModuleExecutableUsage.bind(this);
    this.shellScripts = shellScripts;
  }

  async find({ dir, packageJson }) {
    const [moduleExecutables, shellScripts] = await Promise.all([
      this.getModuleExecutables(dir),
      this.readShellScripts(dir),
    ]);
    const packageJsonScripts = packageJson.scripts || {};
    return this.findModuleExecutableUsage({
      moduleExecutables,
      packageJsonScripts,
      shellScripts,
    });
  }

  findInScript(script, moduleExecutables) {
    const result = [];
    for (const name in moduleExecutables) {
      const executables = moduleExecutables[name];
      for (const executable of Array.from(executables)) {
        if (ModuleNameParser.isGlobalExecutable(executable)) {
          continue;
        }
        if (
          script.match(`\\b${executable}\\b`) &&
          !Array.from(result).includes(name)
        ) {
          result.push(name);
        }
      }
    }
    return result;
  }

  findModuleExecutableUsage({
    moduleExecutables,
    packageJsonScripts,
    shellScripts,
  }) {
    let moduleName;
    const result = [];
    for (const scriptName in packageJsonScripts) {
      const script = packageJsonScripts[scriptName];
      for (moduleName of Array.from(
        this.findInScript(script, moduleExecutables)
      )) {
        result.push({ name: moduleName, script: scriptName });
      }
    }
    for (const filePath in shellScripts) {
      const fileContent = shellScripts[filePath];
      for (moduleName of Array.from(
        this.findInScript(fileContent, moduleExecutables)
      )) {
        result.push({ name: moduleName, file: filePath });
      }
    }
    return result;
  }

  async getModuleExecutables(dir) {
    const nodeModulesBinPath = path.join(dir, 'node_modules', '.bin');
    const files = await glob(`${nodeModulesBinPath}/*`);
    const pairs = await Promise.map(files, this.getModuleExecutablesPair);
    const result = {};
    pairs.forEach(pair => {
      if (result[pair[0]] == null) {
        result[pair[0]] = [];
      }
      result[pair[0]].push(pair[1]);
    });
    return result;
  }

  async getModuleExecutablesPair(binPath) {
    const linkPath = await readlink(binPath);
    const binName = path.basename(binPath);
    const moduleNameParts = linkPath.split(path.sep);
    let moduleName = moduleNameParts[1];
    if (moduleName[0] === '@') {
      moduleName += `/${moduleNameParts[2]}`;
    }
    return [moduleName, binName];
  }

  async readShellScripts(dir, done) {
    const filePaths = await glob(this.shellScripts.root, {
      cwd: dir,
      ignore: this.shellScripts.ignore,
    });
    const fileMapping = _.fromPairs(
      filePaths.map(function(filePath) {
        const fileContentPromise = readFile(path.join(dir, filePath), 'utf8');
        return [filePath, fileContentPromise];
      })
    );
    return Promise.props(fileMapping);
  }
}
