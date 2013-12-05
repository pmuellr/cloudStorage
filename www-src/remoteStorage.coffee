# Licensed under the Apache License. See footer for details.

#URL   = require "url"
path  = require "path"

_       = require "underscore"
cookies = require "cookies-js"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerRemote

    #---------------------------------------------------------------------------
    constructor: (@url) ->
        @xsrfToken = cookies.get "XSRF-TOKEN"

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        @_xhr "GET", "user", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.user

        return null

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        userid = encodeURIComponent userid

        @_xhr "GET", "/u/#{userid}/s", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.storageNames

        return null

    #---------------------------------------------------------------------------
    getStorage: (userid, name) ->
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
        url = path.join @url, uri

        xhr = new XMLHttpRequest

        xhr.onreadystatechange = (e) => @_xhrOnRSC(e, callback)

        xhr.open method, url, true
        xhr.setRequestHeader "Accept",       "application/json"
        xhr.setRequestHeader "Content-Type", "application/json" if requestBody?
        xhr.setRequestHeader "X-XSRF-TOKEN", @xsrfToken         if @xsrfToken?

        if requestBody
            xhr.send requestBody
        else
            xhr.send()

        return

#-------------------------------------------------------------------------------
class StorageRemote

    #---------------------------------------------------------------------------
    constructor: (@manager, userid, name) ->
        @userid = encodeURIComponent userid
        @name   = encodeURIComponent name

    #---------------------------------------------------------------------------
    keys: (callback) ->
        @manager._xhr "GET", "/u/#{@userid}/s/#{@name}", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.keys

        return null

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        key = encodeURIComponent key
        @manager._xhr "GET", "/u/#{@userid}/s/#{@name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.value

        return null

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        key   = encodeURIComponent key
        value = JSON.stringify {value}
        @manager._xhr "PUT", "/u/#{@userid}/s/#{@name}/#{key}", value, (err, response) ->
            return callback err if err?

            callback()

        return null

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        key = encodeURIComponent key

        @manager._xhr "DELETE", "/u/#{@userid}/s/#{@name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback()

        return null

    #---------------------------------------------------------------------------
    clear: (callback) ->
        @manager._xhr "DELETE", "/u/#{@userid}/s/#{@name}", null, (err, response) ->
            return callback err if err?

            callback()

        return null

#-------------------------------------------------------------------------------
httpError = (response) ->
    error = new Error "unexpected http response"
    error.response = response
    return error

#-------------------------------------------------------------------------------
resolveURL = (url) ->

    {protocol, host, pathname} = window.location

    windowURL = "#{protocol}//#{host}#{pathname}"

    return URL.resolve windowURL, url

#-------------------------------------------------------------------------------
errorResult = (name, message) ->
    err = new Error message
    err.name = name

    err

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
