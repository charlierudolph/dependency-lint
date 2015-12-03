# dependency-lint
[![Build Status](https://img.shields.io/circleci/project/charlierudolph/dependency-lint/master.svg)](https://circleci.com/gh/charlierudolph/dependency-lint?)
[![Dependency Status](https://img.shields.io/david/charlierudolph/dependency-lint.svg)](https://david-dm.org/charlierudolph/dependency-lint)
[![NPM Version](https://img.shields.io/npm/v/dependency-lint.svg)](https://www.npmjs.com/package/dependency-lint)

Lints your NPM `dependencies` and `devDependencies` reporting which node modules are
* **missing** and should be added to your `dependencies` or `devDependencies`
* **unused** and should be removed from your `dependencies` or `devDependencies`
* **mislabeled** and should be moved from `dependencies` to `devDependencies` or vice versa

## Installation
```
npm install dependency-lint
```

## Usage
On the command line:
```
dependency-lint
```

## How it works
`dependency-lint` compares the node modules listed in your `package.json` and the node modules it determines are used. A node module is used if:
* it is required in a javascript or coffeescript file
* one of its executables is used in a script in your `package.json`

If you run into an example where `dependency-lint` marks a node module as unused, and you are using it, please create an [issue](https://github.com/charlierudolph/dependency-lint/issues) describing the situation. As a short-term solution, configure `dependency-lint` to allow that node module to be unused.

## Configuration
Create a configuration file with
```
dependency-lint --generate-config (coffee | cson | js | json | yaml | yml)
```
Any options not set in the configuration file will be given there default value.

#### Options
* `allowUnused`
  * array of strings or regular expressions to match against a module name to determine if it is allowed to be unused
  * default: `[]`
  * Please create an [issue](https://github.com/charlierudolph/dependency-lint/issues) anytime you need to use this
* `devFilePatterns`
  * array of path patterns to match againt a filename to determine if it is used only for development (see [minimatch](https://github.com/isaacs/minimatch))
  * default: `['{features,spec,test}/**/*', '**/*_{spec,test}.{coffee,js}']`
* `devScripts`
  * array of strings or regular expressions to match against a script name in your `package.json` to determine if it is used only for development
  * default: `['lint', 'publish', 'test']`
* `ignoreFilePatterns`
  * array of path patterns to match against a filename to determine if it should be ignored (see [minimatch](https://github.com/isaacs/minimatch))
  * default: `['node_modules/**/*']`
* `stripLoaders`
  * boolean whether to ignore anything before a `!` in require statements - allows dependency-lint to be used with webpack
  * default: false
