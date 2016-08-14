gulp = require('gulp')
mocha = require('gulp-mocha')
coffee = require("gulp-coffee")
coffeelint = require('gulp-coffeelint')

gulp.task('lint', -> 
    targets = ['./gulpfile.coffee', './src/**/*.coffee', './tests/**/*.coffee']
    targets.map((target) ->
        gulp.src(target)
            .pipe(coffeelint({
                "indentation": {"value": 4},
                "max_line_length": {"level": "ignore"},
                "no_trailing_whitespace": {"level": "ignore"}
            }))
            .pipe(coffeelint.reporter())
    )
)

gulp.task('test', -> 
    gulp.src('./test/**/*.coffee')
        .pipe(mocha({reporter: 'spec'}))
)

gulp.task('build', -> 
    gulp.src('./src/**/*.coffee')
        .pipe(coffee())
        .pipe(gulp.dest('./lib'))
)

gulp.task('default', ['lint', 'test', 'build'])
