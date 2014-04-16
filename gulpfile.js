var gulp = require('gulp'),
    fs = require('fs'),
    watch = require('gulp-watch'),
    concat = require('gulp-concat'),
    clean = require('gulp-clean'),
    browserify = require('gulp-browserify'),
    plumber = require('gulp-plumber'),
    uglify = require('gulp-uglify'),
    coffee = require('gulp-coffee'),
    rename = require('gulp-rename');


gulp.task('build', function(){
    gulp.src('./src/*.coffee')
        .pipe(plumber())
        .pipe(coffee())
        .pipe(rename({extname: '.js'}))
        .pipe(gulp.dest('./dist/'))

    gulp.src('./src/touchy.coffee', {read: false})
        .pipe(browserify({
            insertGlobals: true,
            transform: ['coffeeify'],
            extensions: ['.coffee']
        }))
        .pipe(rename({extname: '.js'}))
        .pipe(gulp.dest('./test'));

});

var watcher = gulp.watch('./src/*.coffee', ['build']);

gulp.task('default', function(){
    watcher.on('change', function(event){
        console.log('File '+event.path+' was '+event.type+', running tasks...');
    });
});
