# Licensed under the Apache License. See footer for details.

#URL   = require "url"
path  = require "path"

_       = require "underscore"
Q       = require "q"
cookies = require "cookies-js"

#-------------------------------------------------------------------------------
exports.StorageDriver = class ReemoteStorageDriver

    #---------------------------------------------------------------------------
    constructor: (@_url) ->
        @_xsrfToken   = cookies.get "XSRF-TOKEN"

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        @_xhr "GET", "user", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.user

        return

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        @_xhr "GET", "/u/#{userid}/s", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.storageNames

        return

    #---------------------------------------------------------------------------
    keys: (userid, name, callback) ->
        @_xhr "GET", "/u/#{userid}/s/#{name}", null, (err, response) ->
            return callback err if err?

            callback null, response.bodyObject?.keys

        return

    #---------------------------------------------------------------------------
    get: (userid, name, key, callback) ->
        @_xhr "GET", "/u/#{userid}/s/#{name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback null, response.body

        return

    #---------------------------------------------------------------------------
    put: (userid, name, key, value, callback) ->
        @_xhr "PUT", "/u/#{userid}/s/#{name}/#{key}", value, (err, response) ->
            return callback err if err?

            callback()

        return

    #---------------------------------------------------------------------------
    del: (userid, name, key, callback) ->
        @_xhr "DELETE", "/u/#{userid}/s/#{name}/#{key}", null, (err, response) ->
            return callback err if err?

            callback()

        return

    #---------------------------------------------------------------------------
    clear: (userid, name, callback) ->
        @_xhr "DELETE", "/u/#{userid}/s/#{name}", null, (err, response) ->
            return callback err if err?

            callback()

        return

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

    #---------------------------------------------------------------------------
    _xhrOnRSC: (e, callback) ->
        xhr = e.target

        return unless xhr.readyState is 4

        unless xhr.status in [200, 304, 401, 404]
            err = getServerError "invalid HTTP status #{xhr.status}: #{xhr.statusText}"
            return callback err

        contentType = xhr.getResponseHeader "Content-Type"

        response = 
            body: xhr.response

        if contentType.match /json/
            try
                response.bodyObject = JSON.parse response.body
            catch e
                err = getInvalidJSONError "invalid JSON sent from server"
                return callback err

        callback null, response

#-------------------------------------------------------------------------------
getServerError = (message) ->
    err = new Error message
    err.name = "CloudStorage.ServerError"

    err

#-------------------------------------------------------------------------------
getInvalidJSONError = (message) ->
    err = new Error message
    err.name = "CloudStorage.InvalidJSON"

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
