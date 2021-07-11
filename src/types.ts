export interface DependencyLintConfig {
  executedModules: {
    npmScripts: {
      dev: string[]
    }
    shellScripts: {
      dev: string[]
      ignore: string[]
      root: string
    }
  }
  ignoreErrors: {
    missing: string[];
    shouldBeDependency: string[]
    shouldBeDevDependency: string[]
    unused: string[]
  }
  requiredModules: {
    acornParseProps: any
    files: {
      dev: string[]
      ignore: string[];
      root: string
    }
    stripLoaders: boolean
    transpilers: any[]
  }
}
