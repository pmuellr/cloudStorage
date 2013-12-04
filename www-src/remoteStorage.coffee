# Licensed under the Apache License. See footer for details.

URL   = require "url"
path  = require "path"
http  = require "http"
https = require "https"

_       = require "underscore"
cookies = require "cookies-js"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerRemote

    #---------------------------------------------------------------------------
    constructor: (@url) ->
        urlResolved  = URL.resolve window.location.toString(), @url
        urlParsed    = URL.parse urlResolved
        @httpOptions = {protocol, hostname, port, pathname} = urlParsed
        @httpOptions.host = hostname # bug in URL.parse? `host` includes port 

        switch @httpOptions.protocol
            when "http:"  then @httpMod = http
            when "https:" then @httpMod = https
            else 
                throw new Error "invalid URL: #{@url}"

        @xsrfToken = cookies.get "XSRF-TOKEN"

    #---------------------------------------------------------------------------
    getUser: (callback) ->

        @_xhr "GET", "user", null, (err, response) ->
            callback err if err?

            try
                body = JSON.parse(response.body)
            catch e
                callback e

            callback null, body.user

        return null

    #---------------------------------------------------------------------------
    getStorageNames: (callback) ->
        @_xhr "GET", "storage", null, (err, response) ->
            callback err if err?

            try
                body = JSON.parse(response.body)
            catch e
                callback e

            callback null, body.storageNames

        return null

    #---------------------------------------------------------------------------
    getStorage: (name) ->
        return new StorageRemote @, name

    #---------------------------------------------------------------------------
    _xhr: (method, uri, requestBody, callback) ->

        options = _.clone @httpOptions
        options.method   = method
        options.path     = path.join options.path, uri
        options.headers ?= {}
        options.headers["X-XSRF-TOKEN"] = @xsrfToken if @xsrfToken?
        options.headers["Accept"]       = "application/json"

        if requestBody?
            options.headers["Content-Type"] = "application/json"

        responseBody = ""
        request = @httpMod.request options, (response) ->
            response.on "data", (chunk) ->
                responseBody += "#{chunk}"

            response.on "end", ->
                response.body = responseBody
                handleResponse response, callback

        request.on "error", (error) ->
            callback error
        
        request.write requestBody if requestBody?
        request.end()

#-------------------------------------------------------------------------------
handleResponse = (response, callback) ->
    contentType = response.headers["content-type"]
    if contentType.match /.*json.*/
        body = response.body || "null"

        try
            bodyObject = JSON.parse body
        catch e
            bodyObject = null

        response.bodyObject = bodyObject

    switch response.statusCode
        when 200 then # skip

        when 401
            error = Error "unauthorized"
            error.name = "unauthorized"
            callback error
            return

        else
            error = Error "invalid return code #{response.statusCode}"
            error.name = "invalid"
            callback error
            return

    callback null, response

#-------------------------------------------------------------------------------
class StorageRemote

    #---------------------------------------------------------------------------
    constructor: (@manager, name) ->
        @name = encodeURIComponent name

    #---------------------------------------------------------------------------
    keys: (callback) ->
        @manager._xhr "GET", "storage/#{@name}", null, (err, response) ->
            callback err if err?

            callback null, response.bodyObject?.keys

        return null

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        key = encodeURIComponent key
        @manager._xhr "GET", "storage/#{@name}/#{key}", null, (err, response) ->
            callback err if err?

            callback null, response.bodyObject?.value

        return null

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        key   = encodeURIComponent key
        value = JSON.stringify value
        @manager._xhr "PUT", "storage/#{@name}/#{key}", value, (err, response) ->
            callback err if err?

            callback()

        return null

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        key = encodeURIComponent key

        @manager._xhr "DELETE", "storage/#{@name}/#{key}", null, (err, response) ->
            callback err if err?

            callback()

        return null

    #---------------------------------------------------------------------------
    clear: (callback) ->
        @manager._xhr "DELETE", "storage/#{@name}", null, (err, response) ->
            callback err if err?

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
