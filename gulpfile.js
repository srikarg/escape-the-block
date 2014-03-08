var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
var port = 8000;

gulp.task('styles', function() {
    return gulp.src('app/sass/main.scss')
        .pipe(plugins.rubySass({ style: 'compressed' }))
        .pipe(plugins.autoprefixer('last 15 version'))
        .pipe(plugins.rename({ suffix: '.min' }))
        .pipe(gulp.dest('app/css'))
        .pipe(plugins.connect.reload())
        .pipe(plugins.notify({ message: 'Styles are done!' }));
});

gulp.task('scripts', function() {
    return gulp.src('app/coffee/**/*.coffee')
        .pipe(plugins.coffee())
        .pipe(plugins.concat('main.js'))
        .pipe(plugins.jshint.reporter('default'))
        .pipe(plugins.rename({ suffix: '.min' }))
        .pipe(plugins.uglify())
        .pipe(gulp.dest('app/js/src'))
        .pipe(plugins.connect.reload())
        .pipe(plugins.notify({ message: 'Scripts are done!' }));
});

gulp.task('clean', function() {
    return gulp.src(['css', 'js'], {read: false})
        .pipe(plugins.clean())
        .pipe(plugins.notify({ message: 'Clean task complete.' }));
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
