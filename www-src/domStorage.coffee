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

        for i in [0...@_domStorage.length]
            {name, key} = storageKeyParse @_domStorage.key i

            continue unless name? and key?

            names[":#{name}"] = true

        returnedNames = []
        for own name, ignored of names
            returnedNames.push name.substr 1

        process.nextTick -> callback null, returnedNames

        return result

    #---------------------------------------------------------------------------
    getStorage: (userid, name) ->
        throw Error "invalid name" if name.match /^\.+$/

        return new StorageDOM @, name, @_domStorage

#-------------------------------------------------------------------------------
class StorageDOM

    #---------------------------------------------------------------------------
    constructor: (@_manager, @_name, @_domStorage) ->

    #---------------------------------------------------------------------------
    keys: (callback) ->
        {callback, result} = getCallbackAndResult callback

        keys = {}
        for i in [0...@_domStorage.length]
            {name, key} = storageKeyParse @_domStorage.key i

            continue unless (name is @_name) and key?

            keys[":#{key}"] = true

        returnedKeys = []
        for key, ignored of keys
            returnedKeys.push key.substr 1

        process.nextTick -> callback null, returnedKeys

        return result

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        throw Error "invalid key" if key.match /^\.+$/

        {callback, result} = getCallbackAndResult callback

        skey  = storageKeyGenerate @_name, key
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
        throw Error "invalid key" if key.match /^\.+$/

        {callback, result} = getCallbackAndResult callback

        skey  = storageKeyGenerate @_name, key

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
        throw Error "invalid key" if key.match /^\.+$/

        {callback, result} = getCallbackAndResult callback

        skey  = storageKeyGenerate @_name, key
        @_domStorage.removeItem skey

        process.nextTick -> callback()

        return result

    #---------------------------------------------------------------------------
    clear: (callback) ->
        {callback, result} = getCallbackAndResult callback

        @keys (err, keys) =>
            for key in keys
                skey  = storageKeyGenerate @_name, key
                @_domStorage.removeItem skey

            callback()

        return result

#-------------------------------------------------------------------------------
storageKeyGenerate = (name, key) ->
    "cloudStorage/#{encodeURIComponent name}/#{encodeURIComponent key}"

#-------------------------------------------------------------------------------
storageKeyParse = (skey) ->
    name = null
    key  = null

    match = skey.match /cloudStorage\/(.*?)\/(.*)/
    return {name, key} unless match?

    name  = decodeURIComponent match[1]
    key   = decodeURIComponent match[2]

    {name, key}

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
