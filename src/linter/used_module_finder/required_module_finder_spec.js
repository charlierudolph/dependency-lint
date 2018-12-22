import _ from 'lodash';
import { symlink, writeFile } from 'fs-extra';
import getTmpDir from '../../../test/support/get_tmp_dir';
import path from 'path';
import RequiredModuleFinder from './required_module_finder';
import { beforeEach, describe, it } from 'mocha';
import { expect } from 'chai';

const baseBabelExample = {
  filePath: 'server.js',
  filePattern: '**/*.js',
  async setup(tmpDir) {
    const filePath = path.join(tmpDir, '.babelrc');
    const fileContent =
      '{"plugins": ["@babel/plugin-syntax-dynamic-import"], "presets": [["@babel/preset-env", {"targets": "maintained node versions"}]]}';
    return writeFile(filePath, fileContent);
  },
  transpilers: [
    {
      extension: '.js',
      fnName: 'transformSync',
      module: '@babel/core',
      resultKey: 'code',
    },
  ],
};
const baseCoffeeScriptExample = {
  filePath: 'server.coffee',
  filePattern: '**/*.coffee',
  transpilers: [{ extension: '.coffee', module: 'coffee-script' }],
};
const baseJavaScriptExample = {
  filePath: 'server.js',
  filePattern: '**/*.js',
};

const examples = [
  _.assign({}, baseBabelExample, {
    content: 'import myModule from "myModule',
    description: 'invalid babel',
    expectedError: true,
  }),
  _.assign({}, baseBabelExample, {
    content: 'import myModule from "myModule"',
    description: 'babel file requiring a module',
    expectedResult: [{ name: 'myModule', file: 'server.js' }],
  }),
  _.assign({}, baseBabelExample, {
    acornParseProps: { ecmaVersion: 6 },
    content: 'import("myModule")',
    description: 'babel file with a dynamic import',
    expectedResult: [{ name: 'myModule', file: 'server.js' }],
  }),
  _.assign({}, baseCoffeeScriptExample, {
    content: 'myModule = require "myModule',
    description: 'invalid coffeescript',
    expectedError: true,
  }),
  _.assign({}, baseCoffeeScriptExample, {
    content: 'myModule = require "myModule"',
    description: 'coffeescript file requiring a module',
    expectedResult: [{ name: 'myModule', file: 'server.coffee' }],
  }),
  _.assign({}, baseCoffeeScriptExample, {
    content: 'myModule = require.resolve "myModule"',
    description: 'coffeescript file resolving a module',
    expectedResult: [{ name: 'myModule', file: 'server.coffee' }],
  }),
  _.assign({}, baseJavaScriptExample, {
    content: 'var myModule = require("myModule"',
    description: 'invalid javascript',
    expectedError: true,
  }),
  _.assign({}, baseJavaScriptExample, {
    content: 'var myModule = require("myModule");',
    description: 'javascript file requiring a module',
    expectedResult: [{ name: 'myModule', file: 'server.js' }],
  }),
  _.assign({}, baseJavaScriptExample, {
    content: 'var myModule = require.resolve("myModule");',
    description: 'javascript file resolving a module',
    expectedResult: [{ name: 'myModule', file: 'server.js' }],
  }),
  _.assign({}, baseJavaScriptExample, {
    content: 'var myModule = require("myModule");',
    description: 'javascript file with a coffee-script transpiler',
    expectedResult: [{ name: 'myModule', file: 'server.js' }],
    transpilers: [{ extension: '.coffee', module: 'coffee-script' }],
  }),
];

describe('RequiredModuleFinder', function() {
  beforeEach(async function() {
    this.tmpDir = await getTmpDir();
    const nodeModulesPath = path.join(
      __dirname,
      '..',
      '..',
      '..',
      'node_modules'
    );
    await symlink(nodeModulesPath, path.join(this.tmpDir, 'node_modules'));
  });

  describe('find', () =>
    examples.forEach(function(example) {
      const {
        acornParseProps,
        content,
        description,
        expectedError,
        expectedResult,
        filePath,
        filePattern,
        setup,
        transpilers,
      } = example;

      describe(description, function() {
        beforeEach(async function() {
          const finder = new RequiredModuleFinder({
            acornParseProps,
            files: { root: filePattern },
            transpilers,
          });
          await writeFile(path.join(this.tmpDir, filePath), content);
          if (setup) {
            await setup(this.tmpDir);
          }
          try {
            this.result = await finder.find(this.tmpDir);
          } catch (error) {
            if (!expectedError) {
              throw error;
            }
            this.error = error;
          }
        });

        if (expectedError) {
          it('errors with a message that includes the file path', function() {
            expect(this.error.message).to.include(filePath);
          });
        } else {
          it('returns with the required modules', function() {
            expect(this.result).to.eql(expectedResult);
          });
        }
      });
    }));
});
