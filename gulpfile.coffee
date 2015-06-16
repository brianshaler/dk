gulp = require 'gulp'
coffee = require 'gulp-coffee'
changed = require 'gulp-changed'


gulp.task 'build', ->
  gulp.src 'src/**/*.coffee'
  .pipe changed 'lib'
  .pipe coffee()
  .pipe gulp.dest 'lib'

gulp.task 'watch', ['build'], ->
  gulp.watch 'src/**', ['build']

gulp.task 'default', ['build'], ->
