import _ from 'lodash';
import detective from 'detective';
import detectiveEs6 from 'detective-es6';
import { readFile } from 'fs-extra';
import ModuleNameParser from './module_name_parser';
import path from 'path';
import prependToError from '../../util/prepend_to_error';
import Promise from 'bluebird';

const glob = Promise.promisify(require('glob'));

export default class RequiredModuleFinder {
  constructor({ acornParseProps, files, stripLoaders, transpilers }) {
    this.acornParseProps = acornParseProps;
    this.files = files;
    this.stripLoaders = stripLoaders;
    this.transpilers = transpilers;
  }

  compileIfNeeded({ content, dir, filePath }) {
    const ext = path.extname(filePath);
    const transpiler = _.find(this.transpilers, ['extension', ext]);
    if (transpiler) {
      const compiler = require(transpiler.module);
      const fnName = transpiler.fnName || 'compile';
      let result = compiler[fnName](content, {
        cwd: dir,
        filename: path.join(dir, filePath),
      });
      if (transpiler.resultKey) {
        result = result[transpiler.resultKey];
      }
      return result;
    } else {
      return content;
    }
  }

  async find(dir) {
    const files = await glob(this.files.root, {
      cwd: dir,
      ignore: this.files.ignore,
    });
    const results = await Promise.map(files, filePath =>
      this.findInFile({ dir, filePath })
    );
    return _.flatten(results);
  }

  async findInFile({ dir, filePath }) {
    let moduleNames;
    let content = await readFile(path.join(dir, filePath), 'utf8');
    try {
      content = this.compileIfNeeded({ content, dir, filePath });
      const cjsModuleNames = detective(content, {
        parse: this.acornParseProps,
        isRequire: this.isRequire.bind(this),
      });
      const importModulesNames = detectiveEs6(content);
      moduleNames = cjsModuleNames.concat(importModulesNames);
    } catch (err) {
      throw prependToError(err, filePath);
    }
    return (moduleNames = this.normalizeModuleNames({ filePath, moduleNames }));
  }

  isRequire({ type, callee }) {
    return (
      type === 'CallExpression' &&
      ((callee.type === 'Identifier' && callee.name === 'require') ||
        (callee.type === 'MemberExpression' &&
          callee.object.type === 'Identifier' &&
          callee.object.name === 'require' &&
          callee.property.type === 'Identifier' &&
          callee.property.name === 'resolve'))
    );
  }

  normalizeModuleNames({ filePath, moduleNames }) {
    return _.chain(moduleNames)
      .map(this.stripLoaders ? ModuleNameParser.stripLoaders : undefined)
      .reject(ModuleNameParser.isBuiltIn)
      .reject(ModuleNameParser.isRelative)
      .map(ModuleNameParser.stripSubpath)
      .map(name => ({ name, file: filePath }))
      .value();
  }
}

module.exports = RequiredModuleFinder;
