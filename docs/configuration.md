# Configuration

See the default config [here](../config/default.yml)

---
### devFilePatterns
Files used only for development.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
devFilePatterns:
  - '**/*_test.js'
```

---
### devScripts
List of scripts in your `package.json` used only for development.
Passed to `string.match`

Example:
```yml
devScripts:
  - test
```

---
### filePattern
All source files.
Uses [minimatch](https://github.com/isaacs/minimatch)

This is the starting point, `devFilePatterns` and `ignoreFilePatterns` should be
subsets of this pattern.

default:
```yml
filePattern: '**/*.js'
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
### ignoreFilePatterns
Files that should be ignored.
Uses [minimatch](https://github.com/isaacs/minimatch)

Example:
```yml
ignoreFilePatterns:
  - 'dist/**/*'
```

---
### stripLoaders
Whether or not to ignore anything before a `!` in require statements

Useful for [webpack loaders](https://webpack.github.io/docs/loaders.html) and
[RequireJS loader plugins](http://requirejs.org/docs/plugins.html)

Example:
```yml
stripLoaders: true
```

---
### transpilers
Transpiles code to javascript based on its extension.
Each transpiler should specify an `extension` and a `module`.

For each file with `extension`, the following will be called:
```js
require(module).compile(fileContents, {filename: filePath});
```

If the transpiler you're using doesn't follow this pattern, please open an [issue](https://github.com/charlierudolph/dependency-lint/issues)

Example:
```yml
transpilers:
  - extension: .coffee
    module: coffee-script
```
