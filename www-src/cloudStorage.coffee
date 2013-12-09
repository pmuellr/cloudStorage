# Licensed under the Apache License. See footer for details.

Q = require "q"
_ = require "underscore"

pkg     = require "./package.json"
builtOn = require "./builtOn.json"

domStorage    = require "./domStorage"
remoteStorage = require "./remoteStorage"

window.cloudStorage = exports

#-------------------------------------------------------------------------------
cloudStorage.version = pkg.version

#-------------------------------------------------------------------------------
cloudStorage.browserStorageManager = (type) ->
    switch type

        when "local" 
            driver = new domStorage.StorageDriver window.localStorage
            return new StorageManager driver

        when "session"
            driver = new domStorage.StorageDriver window.sessionStorage
            return new StorageManager driver

        else
            throw Error "invalid type: #{type}"

#-------------------------------------------------------------------------------
cloudStorage.remoteStorageManager = (url) ->
    driver = new remoteStorage.StorageDriver url
    return new StorageManager driver

#-------------------------------------------------------------------------------
class StorageManager

    #---------------------------------------------------------------------------
    constructor: (@_driver) ->

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @_driver.getUser callback

        return result

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        {callback, result} = getCallbackAndResult callback

        tokens = {userid}
        return result unless normalizeTokens tokens, callback
        {userid} = tokens

        @_driver.getStorageNames userid, (err, names) ->
            return callback err if err?

            names = for name in names
                denormalizeToken name

            callback null, names

        return result

    #---------------------------------------------------------------------------
    getStorage: (userid, name) ->
        tokens = {userid, name}
        normalizeTokens tokens, (err) -> throw err if err?
        {userid, name} = tokens

        return new Storage @, userid, name

#-------------------------------------------------------------------------------
class Storage

    #---------------------------------------------------------------------------
    constructor: (@_manager, @_userid, @_name) ->
        {@_driver} = @_manager
        @_meta = 
            etags: {}

    #---------------------------------------------------------------------------
    keys: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @_driver.keys @_userid, @_name, (err, keys) ->
            return callback err if err?

            keys = for key in keys
                denormalizeToken key

            callback null, keys

        return result

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        tokens = {key}
        return result unless normalizeTokens tokens, callback
        {key} = tokens

        @_driver.get @_userid, @_name, key, (err, value) ->
            return callback err if err?

            if value?
                try 
                    value = (JSON.parse value).value
                catch e
                    return callback getInvalidJSONError "value was not parse-able"
            else
                value = null
            
            callback null, value

        return result

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        {callback, result} = getCallbackAndResult callback

        try
            value = JSON.stringify {value}
        catch e
            process.nextTick -> callback getInvalidJSONError "value was not stringify-able"
            return result
        
        tokens = {key}
        return result unless normalizeTokens tokens, callback
        {key} = tokens

        @_driver.put @_userid, @_name, key, value, callback

        return result

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        tokens = {key}
        return result unless normalizeTokens tokens, callback
        {key} = tokens

        @_driver.del @_userid, @_name, key, callback

        return result

    #---------------------------------------------------------------------------
    clear: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @_driver.clear @_userid, @_name, callback

        return result

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
normalizeTokens = (object, callback) ->
    for own key, val of object
        val = "" unless val?
        err = "invalid #{key}: #{val}" if val.match /^\.+$/

        if err?
            callback getInvalidParameterError err
            return false

        object[key] = encodeURIComponent val

    return true

#-------------------------------------------------------------------------------
denormalizeToken = (token) ->
    return decodeURIComponent token

#-------------------------------------------------------------------------------
getInvalidJSONError = (message) ->
    err = new Error message
    err.name = "CloudStorage.InvalidJSON"

    err

#-------------------------------------------------------------------------------
getInvalidParameterError = (message) ->
    err = new Error message
    err.name = "CloudStorage.InvalidParameter"

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
