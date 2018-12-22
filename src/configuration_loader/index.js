import _ from 'lodash';
import { access, readFile } from 'fs-extra';
import path from 'path';
import yaml from 'js-yaml';

export default class ConfigurationLoader {
  constructor() {
    this.defaultConfigPath = path.join(
      __dirname,
      '..',
      '..',
      'config',
      'default.yml'
    );
  }

  async load(dir) {
    const [defaultConfig, userConfig] = await Promise.all([
      this.loadDefaultConfig(),
      this.loadUserConfig(dir),
    ]);
    const customizer = function(objValue, srcValue) {
      if (_.isArray(srcValue)) {
        return srcValue;
      }
    };
    return _.mergeWith({}, defaultConfig, userConfig, customizer);
  }

  async loadConfig(filePath) {
    const content = await readFile(filePath, 'utf8');
    return yaml.safeLoad(content, { filename: filePath });
  }

  loadDefaultConfig() {
    return this.loadConfig(this.defaultConfigPath);
  }

  async loadUserConfig(dir) {
    const userConfigPath = path.join(dir, 'dependency-lint.yml');
    try {
      await access(userConfigPath);
    } catch (error) {
      return {};
    }
    return this.loadConfig(userConfigPath);
  }
}
