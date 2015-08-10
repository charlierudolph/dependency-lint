require 'coffee-script/register' # implicitly required by the gulp CLI
gulp = require 'gulp'
gulpChanged = require 'gulp-changed'
gulpCoffee = require 'gulp-coffee'


src = 'src'
dest = 'lib'
paths =
  js: ["#{src}/**/*.coffee", '!**/*_spec.coffee']


gulp.task 'js', ->
  srcOpts = base: src

  gulp
    .src paths.js, srcOpts
    .pipe gulpChanged dest, extension: '.js'
    .pipe gulpCoffee()
    .on 'error', (error) ->
      console.error error.toString()
      @emit('end')
    .pipe gulp.dest dest


gulp.task 'watch', ['js'], ->
  gulp.watch paths.js, ['js']


gulp.task 'default', ['js']
