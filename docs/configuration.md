# Configuration

See the default config [here](../config/default.yml)

---
### allowUnused
List of modules that are allowed to be unused.
Passed to `string.match`

Please create an [issue](https://github.com/charlierudolph/dependency-lint/issues)
anytime you need to use this

Example:
```yml
allowUnused:
  - mocha
```

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
Maps file extension to a compile function.
Should be an array of objects with properties `extension` and `module`

The `module` will be required and then the `compile` property will be called
with the file contents and the file path for each file with that `extension`

```js
require(module).compile(fileContents, {filename: filePath});
```

Example:
```yml
transpilers:
  - extension: .coffee
    module: coffee-script
```
