# Licensed under the Apache License. See footer for details.

_ = require "underscore"
Q = require "q"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerDOM 

    #---------------------------------------------------------------------------
    constructor: (@domStorage) ->

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        {callback, result} = getCallbackAndResult callback

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        {callback, result} = getCallbackAndResult callback

        names = {}

        pattern = /cloudStorage\.(.*)/

        for i in [0...@domStorage.length]
            key = @domStorage.key i

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

        storage = @domStorage.getItem "cloudStorage.#{name}"
        unless storage?
            storage = "{}"

        try
            storage = JSON.parse storage
        catch e
            storage = {}
        
        return new StorageDOM @, name, storage

    #---------------------------------------------------------------------------
    _store: (name, storage) ->
        try 
            storage = JSON.stringify storage
        catch e
            return

        @domStorage.setItem "cloudStorage.#{name}", storage

    #---------------------------------------------------------------------------
    _delete: (name) ->

        @domStorage.removeItem "cloudStorage.#{name}"

#-------------------------------------------------------------------------------
class StorageDOM

    #---------------------------------------------------------------------------
    constructor: (@manager, @name, @storage) ->

    #---------------------------------------------------------------------------
    keys: (callback) ->
        {callback, result} = getCallbackAndResult callback

        returnedKeys = []

        for key, val of @storage
            returnedKeys.push key.substr 1

        process.nextTick -> callback null, returnedKeys

        return result

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        result = @storage[":#{key}"]

        process.nextTick -> callback null, result

        return result

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        {callback, result} = getCallbackAndResult callback

        @storage[":#{key}"] = value
        @manager._store @name, @storage

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        {callback, result} = getCallbackAndResult callback

        delete @storage[":#{key}"]
        @manager._store @name, @storage

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    clear: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @storage = {}
        @manager._delete @name

        process.nextTick -> callback()

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
