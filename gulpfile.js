var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
var pump = require('pump');
var port = 8000;

gulp.task('styles', function() {
    return plugins.rubySass('app/sass/main.scss', { style: 'compressed' })
        .pipe(plugins.autoprefixer('last 15 version'))
        .pipe(plugins.rename({ suffix: '.min' }))
        .pipe(gulp.dest('app/css'))
        .pipe(plugins.connect.reload());
});

gulp.task('scripts', function(cb) {
    pump([
        gulp.src('app/coffee/**/*.coffee'),
        plugins.coffee(),
        plugins.concat('main.js'),
        plugins.jshint.reporter('default'),
        plugins.rename({ suffix: '.min' }),
        plugins.uglify(),
        gulp.dest('app/js/src'),
        plugins.connect.reload()
    ],
    cb
    );
});

gulp.task('clean', function() {
    return gulp.src(['css', 'js'], {read: false})
        .pipe(plugins.clean());
});

gulp.task('connect', plugins.connect.server({
    root: 'app',
    port: port,
    livereload: true,
    open: {
        browser: 'Google Chrome'
    }
}));

gulp.task('watch', ['connect'], function() {
    gulp.watch('app/index.html', plugins.connect.reload());
    gulp.watch('app/sass/**/*.scss', ['styles']);
    gulp.watch('app/coffee/**/*.coffee', ['scripts']);
});

gulp.task('default', ['clean', 'connect', 'styles', 'scripts', 'watch']);
gulp.task('build', ['clean', 'connect', 'styles', 'scripts']);
