# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------

fs            = require "fs"
path          = require "path"
zlib          = require "zlib"

require "shelljs/global"
_ = require "underscore"

__basename = path.basename __filename

mkdir "-p", "tmp"

#-------------------------------------------------------------------------------

grunt = null

Config =

    bower:
        jquery:
            version: "2.0.x"
            files:
                "jquery.js":  "."

    watch:
        Gruntfile:
            files: __basename
            tasks: "gruntfile-changed"
        source:
            files: [ 
                "lib-src/**/*"
                "lib-test/*.coffee" 
                "www-src/**/*"
                "www-test/*.coffee" 
            ]
            tasks: "build-n-serve"
            options:
                atBegin:    true
                interrupt:  true

    server:
        cmd: "node_modules/.bin/coffee lib-test/server.coffee"
        pidFile: path.join __dirname, "tmp", "server.pid"

    clean: [
        "node_modules"
        "tmp"
    ]

#-------------------------------------------------------------------------------
module.exports = (Grunt) ->
    grunt = Grunt

    grunt.initConfig Config

    grunt.registerTask "default", ["help"]

    grunt.registerTask "help", "print help", ->
        exec "grunt --help"

    grunt.loadNpmTasks "grunt-contrib-watch"

    grunt.registerTask "build", "run a build", ->
        build @

    grunt.registerTask "bower", "get bower files", ->
        bower @

    grunt.registerTask "serve", "run the server", ->
        serve @

    grunt.registerTask "clean", "remove transient files", ->
        clean @

    grunt.registerTask "----------------", "remaining tasks are internal", ->

    grunt.registerTask "serverStart", "start the server", ->
        serverStart @

    grunt.registerTask "serverStop", "stop the server", ->
        serverStop @

    grunt.registerTask "build-n-serve", "run a build, start the server", ->
        grunt.task.run ["build", "serve"]

    grunt.registerTask "gruntfile-changed", "exit when the Gruntfile changes", ->
        grunt.log.write "Gruntfile changed, maybe you wanna exit and restart?"

#-------------------------------------------------------------------------------
build = (task) ->
    done = task.async()

    timeStart = Date.now()

    bower() unless test "-d", "bower_components"

    #----------------------------------
    log "building server code in lib"

    cleanDir "lib"

    coffeec "--map --output lib lib-src/*.coffee"
    createBuiltOn "lib/builtOn.json"

    #----------------------------------
    log "building client code in www"

    cleanDir "www"
    cleanDir "tmp/www"

    coffeec "--output tmp www-src/*.coffee"

    args = "--debug --extension .coffee --transform coffeeify --outfile tmp/cloudstorage-browser.js --entry www-src/cloudStorage.coffee"

    log "browserify #{args}"
    browserify args

    catSourceMap "--fixFileNames tmp/cloudStorage-browser.js www/cloudStorage-browser.js"

    #----------------------------------
    log "building test code in www-test"
    coffeec "--output www-test www-test/*.coffee"

    done()

    return

#-------------------------------------------------------------------------------
bower = ->
    cleanDir "bower_components"

    unless which "bower"
        logError "bower must be globally installed"

    for name, {version, files} of Config.bower
        exec "bower install #{name}##{version}"
        log ""

#-------------------------------------------------------------------------------
serve = (task) ->
    grunt.task.run ["serverStop", "serverStart"]

#-------------------------------------------------------------------------------
serverStart = (task) ->
    serverSpawn Config.server.pidFile, "node", Config.server.cmd.split(" ")
    task.async()

#-------------------------------------------------------------------------------
serverStop = ->
    serverKill Config.server.pidFile

#-------------------------------------------------------------------------------
clean = ->
    for dir in Config.clean
        if test "-d", dir
            rm "-rf", dir

#-------------------------------------------------------------------------------
cleanDir = (dirs...) ->
    for dir in dirs
        mkdir "-p",  dir
        rm "-rf", "#{dir}/*"

#-------------------------------------------------------------------------------
createBuiltOn = (oFile) ->
    content = JSON.stringify {date: new Date}, null, 4
    content.to oFile

#-------------------------------------------------------------------------------
serverSpawn = (pidFile, cmd, args, opts={}) ->
    opts.stdio = "inherit"

    serverProcess = grunt.util.spawn {cmd, args, opts}, ->

    log "starting server process #{serverProcess.pid}"
    serverProcess.pid.toString().to pidFile

#-------------------------------------------------------------------------------
serverKill = (pidFile) ->
    unless test "-f", pidFile
        log "no pidfile, no server to kill"
        return

    pid = cat pidFile
    pid = parseInt pid, 10
    rm pidFile

    try
        log "killing  server process #{pid}"
        process.kill pid
    catch e

#-------------------------------------------------------------------------------

coffee       = (parms) ->  exec "node_modules/.bin/coffee #{parms}"
coffeec      = (parms) ->  coffee "--bare --compile #{parms}"
browserify   = (parms) ->  exec "node_modules/.bin/browserify #{parms}"
catSourceMap = (parms) ->  exec "node_modules/.bin/cat-source-map #{parms}"

#-------------------------------------------------------------------------------
log = (message) ->
    grunt.log.write "#{message}\n"

#-------------------------------------------------------------------------------
logError = (message) ->
    grunt.fail.fatal "#{message}\n"

#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
