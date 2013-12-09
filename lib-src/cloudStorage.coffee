# Licensed under the Apache License. See footer for details.

path = require "path"

_ = require "underscore"

cloudStorage = exports

#-------------------------------------------------------------------------------
cloudStorage.configure = (app, storageDriver) ->
    checkStorageDriver storageDriver

    app.all "*", setUserid storageDriver

    dmw = new DriverMiddleWare storageDriver

    app.get    "/user",                  (req,res)->  dmw.getUser         req, res
    app.get    "/u/:user/s",             (req,res)->  dmw.getStorageNames req, res
    app.get    "/u/:user/s/:name",       (req,res)->  dmw.keys            req, res
    app.delete "/u/:user/s/:name",       (req,res)->  dmw.clear           req, res
    app.get    "/u/:user/s/:name/:key",  (req,res)->  dmw.get             req, res
    app.put    "/u/:user/s/:name/:key",  (req,res)->  dmw.put             req, res
    app.delete "/u/:user/s/:name/:key",  (req,res)->  dmw.del             req, res

    return app

#-------------------------------------------------------------------------------
checkStorageDriver = (storageDriver) ->
    methods = [
        "getUserID"      
        "getUser"        
        "getStorageNames"
        "keys"           
        "clear"          
        "get"            
        "put"            
        "del"            
    ]

    for method in methods
        unless _.isFunction storageDriver[method]
            return SDMissingMethodError storageDriver, method

    return

#-------------------------------------------------------------------------------
SDMissingMethodError = (storageDriver, method) ->
    throw Error "missing method on storageDriver: #{method} (driver: #{storageDriver})"

#-------------------------------------------------------------------------------
setUserid = (storageDriver) ->
    (request, response, next) ->
        storageDriver.getUserID request, (err, userid) ->
            return response.send errorResult err if err?

            request.cloudStorage =
                userid: userid

            next()

#-------------------------------------------------------------------------------
class DriverMiddleWare

    #---------------------------------------------------------------------------
    constructor: (@storageDriver) ->

    #---------------------------------------------------------------------------
    _initTx: (request, response) ->
        request:  request
        response: response
        authUser: request?.cloudStorage?.userid

    #---------------------------------------------------------------------------
    getUser: (request, response) ->
        tx = @_initTx request, response

        @storageDriver.getUser tx, (err, user) ->
            return response.send errorResult err if err?

            response.set "Cache-Control", "no-cache"
            response.send
                status: "ok"
                user:   user

        return

    #---------------------------------------------------------------------------
    getStorageNames: (request, response) ->
        tx   = @_initTx request, response
        user = request.params.user

        @storageDriver.getStorageNames tx, user, (err, storageNames) ->
            return response.send errorResult err if err?
            
            response.send
                status:       "ok"
                storageNames: storageNames

        return

    #---------------------------------------------------------------------------
    keys: (request, response) ->
        tx   = @_initTx request, response
        user = request.params.user
        name = request.params.name

        @storageDriver.keys tx, user, name, (err, keys) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"
                keys:   keys

        return

    #---------------------------------------------------------------------------
    clear: (request, response) ->
        tx   = @_initTx request, response
        user = request.params.user
        name = request.params.name

        @storageDriver.clear tx, user, name, (err) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"

        return

    #---------------------------------------------------------------------------
    get: (request, response) ->
        tx   = @_initTx request, response
        user = request.params.user
        name = request.params.name
        key  = request.params.key

        @storageDriver.get tx, user, name, key, (err, value) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"
                key:    key
                value:  value

        return


    #---------------------------------------------------------------------------
    put: (request, response) ->
        tx    = @_initTx request, response
        user  = request.params.user
        name  = request.params.name
        key   = request.params.key
        value = request?.body?.value

        @storageDriver.put tx, user, name, key, value, (err) ->
            return response.send errorResult err if err?
            
            response.send
                status: "ok"

        return

    #---------------------------------------------------------------------------
    del: (request, response) ->
        tx   = @_initTx request, response
        user = request.params.user
        name = request.params.name
        key  = request.params.key

        @storageDriver.del tx, user, name, key, (err, value) ->
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
