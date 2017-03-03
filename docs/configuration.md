# Configuration

See the default config [here](../config/default.yml)

---
### executedModules
Configuration for finding all the instances where modules are executed.

### executedModules.npmScripts.dev
List of scripts in your `package.json` used only for development.
Passed to `string.match`

Example:
```yml
executedModules:
  npmScripts:
    dev:
      - test
```

### executedModules.shellScripts.dev
Shell scripts used only for development.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
executedModules:
  shellScripts:
    dev:
      - bin/test
```

### executedModules.shellScripts.ignore
Shell scripts that should be ignored.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
executedModules:
  shellScripts:
    ignore:
      - node_modules/**/*
```

### executedModules.shellScripts.root
All shell scripts.
Uses [minimatch](https://github.com/isaacs/minimatch)

This is the starting point, `executedModules.shellScripts.dev` and `executedModules.shellScripts.ignore` should be
subsets of this pattern.

Example:
```yml
executedModules:
  shellScripts:
    root: 'bin/*'
```

---
### ignoreErrors
Mapping from error to a list of modules that will be ignored.
Passed to `string.match`

Please create an [issue](https://github.com/charlierudolph/dependency-lint/issues)
anytime you need to use this

Example:
```yml
ignoreErrors:
  missing: []
  shouldBeDependency: []
  shouldBeDevDependency: []
  unused:
    - mocha
```

---
### requiredModules
Configuration for finding all the instances where modules are required.

### requiredModules.acornParseProps
Options passed to [detective](https://github.com/substack/node-detective) which is passes
onto [acorn](https://www.npmjs.com/package/acorn)

default:
```yml
requiredModules:
  acornParseProps:
    ecmaVersion: 6
```


### requiredModules.files.dev
Files used only for development.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
requiredModules:
  files:
    dev:
      - '**/*_test.js'
```

### requiredModules.files.ignore
Files that should be ignored.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
requiredModules:
  files:
    ignore:
      - 'dist/**/*'
```

### requiredModules.files.root
All source files.
Uses [minimatch](https://github.com/isaacs/minimatch)

This is the starting point, `requiredModules.files.dev` and `requiredModules.files.ignore` should be
subsets of this pattern.

default:
```yml
requiredModules:
  files:
    root: '**/*.js'
```

### requiredModules.stripLoaders
Whether or not to ignore anything before a `!` in require statements

Useful for [webpack loaders](https://webpack.github.io/docs/loaders.html) and
[RequireJS loader plugins](http://requirejs.org/docs/plugins.html)

Example:
```yml
requiredModules:
  stripLoaders: true
```

### requiredModules.transpilers
Transpiles code to javascript based on its extension.
Each transpiler should specify an `extension` and a `module` and optionally a `fnName` (which defaults to `compile`) and a `resultKey`.

For each file with `extension`, the following will be called:
```js
var result = require(module)[fnName](fileContents, {filename: filePath});
if (resultKey) {
  result = result[resultKey]
}
```

If the transpiler you're using doesn't fit into this pattern, please open an [issue](https://github.com/charlierudolph/dependency-lint/issues)

Example:
```yml
requiredModules:
  transpilers:
    - extension: .coffee
      module: coffee-script # 1.9.0

    - extension: .js
      fnName: transform
      module: babel-core # 6.17.0
      resultKey: code

    - extension: .ls
      module: livescript # 1.5.0
```
