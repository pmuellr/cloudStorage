# Licensed under the Apache License. See footer for details.

#URL   = require "url"
path  = require "path"

_       = require "underscore"
Q       = require "q"
cookies = require "cookies-js"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerRemote

    #---------------------------------------------------------------------------
    constructor: (@_url) ->
        @_xsrfToken   = cookies.get "XSRF-TOKEN"

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @_xhr "GET", "user", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.user

        return result

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        throw Error "invalid userid" if userid.match /^\.+$/

        {callback, result} = getCallbackAndResult callback

        userid = encodeURIComponent userid

        @_xhr "GET", "/u/#{userid}/s", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.storageNames

        return result

    #---------------------------------------------------------------------------
    getStorage: (userid, name) ->
        throw Error "invalid userid" if userid.match /^\.+$/
        throw Error "invalid name"   if name.match   /^\.+$/

        return new StorageRemote @, userid, name

    #---------------------------------------------------------------------------
    _xhrOnRSC: (e, callback) ->
        xhr = e.target

        return unless xhr.readyState is 4

        unless xhr.status is 200
            message = "invalid HTTP status #{xhr.status}: #{xhr.statusText}"
            return callback errorResult "ServerError", message

        contentType = xhr.getResponseHeader "Content-Type"

        response = 
            body: xhr.response

        if contentType.match /json/
            try
                response.bodyObject = JSON.parse response.body
            catch e
                message = "invalid JSON sent from server"
                return callback errorResult "ServerError", message

        callback null, response

    #---------------------------------------------------------------------------
    _xhr: (method, uri, requestBody, callback) ->
        url = path.join @_url, uri

        xhr = new XMLHttpRequest

        xhr.onreadystatechange = (e) => @_xhrOnRSC(e, callback)

        xhr.open method, url, true
        xhr.setRequestHeader "Accept",       "application/json"
        xhr.setRequestHeader "Content-Type", "application/json" if requestBody?
        xhr.setRequestHeader "X-XSRF-TOKEN", @_xsrfToken        if @_xsrfToken?

        if requestBody
            xhr.send requestBody
        else
            xhr.send()

        return

#-------------------------------------------------------------------------------
class StorageRemote

    #---------------------------------------------------------------------------
    constructor: (@manager, userid, name) ->
        @_userid = encodeURIComponent userid
        @_name   = encodeURIComponent name
        @_meta   = {}

    #---------------------------------------------------------------------------
    keys: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @manager._xhr "GET", "/u/#{@_userid}/s/#{@_name}", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.keys

        return result

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        throw Error "invalid key" if key.match /^\.+$/

        {callback, result} = getCallbackAndResult callback

        key = encodeURIComponent key
        @manager._xhr "GET", "/u/#{@_userid}/s/#{@_name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.value

        return result

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        throw Error "invalid key" if key.match /^\.+$/
        
        {callback, result} = getCallbackAndResult callback

        key   = encodeURIComponent key
        value = JSON.stringify {value}

        @manager._xhr "PUT", "/u/#{@_userid}/s/#{@_name}/#{key}", value, (err, response) ->
            return callback err if err?

            callback()

        return result

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        throw Error "invalid key" if key.match /^\.+$/
        
        {callback, result} = getCallbackAndResult callback

        key = encodeURIComponent key

        @manager._xhr "DELETE", "/u/#{@_userid}/s/#{@_name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback()

        return result

    #---------------------------------------------------------------------------
    clear: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @manager._xhr "DELETE", "/u/#{@_userid}/s/#{@_name}", null, (err, response) ->
            return callback err if err?

            callback()

        return result

#-------------------------------------------------------------------------------
errorResult = (name, message) ->
    err = new Error message
    err.name = name

    err

#-------------------------------------------------------------------------------
getCallbackAndResult = (callback) ->
    result = null

    return {callback, result} if _.isFunction callback

    deferred = Q.defer()
    result   = deferred.promise

    callback = (err, value) ->
        if err?
            deferred.reject err
        else
            deferred.resolve value

    return {callback, result}

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
