# Configuration Options


### allowUnused
array of strings or regular expressions to match against a module name
to determine if it is allowed to be unused

Please create an [issue](https://github.com/charlierudolph/dependency-lint/issues)
anytime you need to use this

default:
```yml
allowUnused: []
```

### devFilePatterns
array of path patterns to match against a filename to determine if it is used
only for development (see [minimatch](https://github.com/isaacs/minimatch))

default:
```yml
devFilePatterns:
  - '{features,spec,test}/**/*'
  - '**/*_{spec,test}.js'
```

### devScripts
array of strings or regular expressions to match against a script name
in your `package.json` to determine if it is used only for development

default:
```yml
devScripts:
  - lint
  - publish
  - test
```

### filePattern
path pattern to match against a filename to determine if it should be parsed
(see [minimatch](https://github.com/isaacs/minimatch))

This is the starting point, devFilePatterns and ignoreFilePatterns should be
subsets of this pattern

default:
```yml
filePattern: '**/*.js'
```

### ignoreFilePatterns
array of path patterns to match against a filename to determine if it should be
ignored (see [minimatch](https://github.com/isaacs/minimatch))

default:
```yml
ignoreFilePatterns:
  - 'node_modules/**/*'
```

### stripLoaders
boolean whether to ignore anything before a `!` in require statements

Useful for [webpack loaders](https://webpack.github.io/docs/loaders.html) and
[RequireJS loader plugins](http://requirejs.org/docs/plugins.html)

default:
```yml
stripLoaders: false
```

### transpilers
array of objects with properties 'extension' and 'module'.

The module will be required and then the 'compile' property will be called
with the file contents and the file path for each file with that extension

```js
require(module).compile(fileContents, {filename: filePath});
```

default:
```yml
transpilers: []
```
