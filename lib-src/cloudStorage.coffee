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
            return response.send errorResult err if err?

            response.send
                status: "ok"
                user:   "#{user}"

        return

    #---------------------------------------------------------------------------
    getStorageNames: (request, response) ->
        @storageManager.getStorageNames request, (err, storageNames) ->
            return response.send errorResult err if err?
            
            response.send
                status:       "ok"
                storageNames: storageNames

        return

    #---------------------------------------------------------------------------
    keys: (request, response) ->
        name = request.params.name

        @storageManager.keys request, name, (err, keys) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"
                keys:   keys

        return

    #---------------------------------------------------------------------------
    clear: (request, response) ->
        name = request.params.name

        @storageManager.clear request, name, (err) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"

        return

    #---------------------------------------------------------------------------
    get: (request, response) ->
        name = request.params.name
        key  = request.params.key

        @storageManager.get request, name, key, (err, value) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"
                key:    key
                value:  value

        return


    #---------------------------------------------------------------------------
    put: (request, response) ->
        name  = request.params.name
        key   = request.params.key
        value = request?.body?.value

        @storageManager.put request, name, key, value, (err) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"

        return

    #---------------------------------------------------------------------------
    del: (request, response) ->
        name = request.params.name
        key  = request.params.key

        @storageManager.del request, name, key, (err, value) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"

        return

#-------------------------------------------------------------------------------
errorResult = (err) ->
    status:  "StorageError"    
    name:    "#{err.name}"
    message: "#{err.message}"

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
