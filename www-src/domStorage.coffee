# Licensed under the Apache License. See footer for details.

_ = require "underscore"
Q = require "q"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerDOM 

    #---------------------------------------------------------------------------
    constructor: (@_domStorage) ->

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        {callback, result} = getCallbackAndResult callback

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        {callback, result} = getCallbackAndResult callback

        names = {}

        pattern = /cloudStorage\.(.*?)\.(.*)/

        for i in [0...@_domStorage.length]
            key = @_domStorage.key i

            match = key.match pattern
            continue unless match

            name = ":#{match[1]}"
            names[name] = true

        returnedNames = []
        for own name, ignored of names
            returnedNames.push name.substr 1

        process.nextTick -> callback null, returnedNames

        return result

    #---------------------------------------------------------------------------
    getStorage: (userid, name) ->
        return new StorageDOM @, name, @_domStorage

#-------------------------------------------------------------------------------
class StorageDOM

    #---------------------------------------------------------------------------
    constructor: (@_manager, @_name, @_domStorage) ->

    #---------------------------------------------------------------------------
    keys: (callback) ->
        {callback, result} = getCallbackAndResult callback

        pattern = /cloudStorage\.(.*?)\.(.*)/

        keys = {}
        for i in [0...@_domStorage.length]
            key = @_domStorage.key i

            match = key.match pattern
            continue unless match
            continue unless match[1] is @_name

            keys[":#{match[2]}"] = true

        returnedKeys = []
        for key, ignored of keys
            returnedKeys.push key.substr 1

        process.nextTick -> callback null, returnedKeys

        return result

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        skey  = "cloudStorage.#{@_name}.#{key}"
        value = @_domStorage.getItem skey

        try
            value = JSON.parse value
        catch e
            process.nextTick -> callback e
            return result

        process.nextTick -> callback null, value

        return result

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        {callback, result} = getCallbackAndResult callback

        skey = "cloudStorage.#{@_name}.#{key}"

        try
            value = JSON.stringify value
        catch e
            process.nextTick -> callback e
            return result

        @_domStorage.setItem skey, value

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        skey = "cloudStorage.#{@_name}.#{key}"
        @_domStorage.removeItem skey

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    clear: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @keys (err, keys) =>
            for key in keys
                skey = "cloudStorage.#{@_name}.#{key}"
                @_domStorage.removeItem skey

            callback()

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
