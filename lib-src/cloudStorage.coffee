# Licensed under the Apache License. See footer for details.

path = require "path"

cloudStorage = exports

#-------------------------------------------------------------------------------
cloudStorage.configure = (app, storageManager) ->
    handler = new Handler storageManager

    app.get    "/user",                  (req, res) -> handler.getUser         req, res
    app.get    "/storage",               (req, res) -> handler.getStorageNames req, res
    app.get    "/storage/:name",         (req, res) -> handler.keys            req, res
    app.delete "/storage/:name",         (req, res) -> handler.clear           req, res
    app.get    "/storage/:name/:key",    (req, res) -> handler.get             req, res
    app.put    "/storage/:name/:key",    (req, res) -> handler.put             req, res
    app.delete "/storage/:name/:key",    (req, res) -> handler.del             req, res

    return app

#-------------------------------------------------------------------------------
class Handler 

    #---------------------------------------------------------------------------
    constructor: (@storageManager) ->

    #---------------------------------------------------------------------------
    getUser: (request, response) ->
        @storageManager.getUser request, (err, user) ->
            if err?
                return response.send 500, "#{err}"

            response.send {user}

        return

    #---------------------------------------------------------------------------
    getStorageNames: (request, response) ->
        @storageManager.getStorageNames request, (err, storageNames) ->
            if err?
                return response.send 500, "#{err}"

            response.send {storageNames}

        return

    #---------------------------------------------------------------------------
    keys: (request, response) ->
        name = request.params.name

        @storageManager.keys request, name, (err, keys) ->
            if err?
                return response.send 500, "#{err}"

            response.send {keys}

        return

    #---------------------------------------------------------------------------
    clear: (request, response) ->
        name = request.params.name

        @storageManager.clear request, name, (err) ->
            if err?
                return response.send 500, "#{err}"

            response.send 200

        return

    #---------------------------------------------------------------------------
    get: (request, response) ->
        name = request.params.name
        key  = request.params.key

        @storageManager.get request, name, key, (err, value) ->
            if err?
                return response.send 500, "#{err}"

            response.send {value}

        return


    #---------------------------------------------------------------------------
    put: (request, response) ->
        name  = request.params.name
        key   = request.params.key
        value = request.body
        console.log "cloudStorage::put(#{name}, #{key}, #{JSON.stringify value})"

        @storageManager.put request, name, key, value, (err) ->
            if err?
                return response.send 500, "#{err}"

            response.send 200

        return

    #---------------------------------------------------------------------------
    del: (request, response) ->
        name = request.params.name
        key  = request.params.key

        @storageManager.del request, name, key, (err, value) ->
            if err?
                return response.send 500, "#{err}"

            response.send 200

        return

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
