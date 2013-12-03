# Licensed under the Apache License. See footer for details.

_ = require "underscore"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerDOM 

    #---------------------------------------------------------------------------
    constructor: (@domStorage) ->

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        process.nextTick -> 
            callback() if _.isFunction callback

        return null

    #---------------------------------------------------------------------------
    getStorageNames: (callback) ->
        names = {}

        pattern = /cloudStorage\.(.*)/

        for i in [0...@domStorage.length]
            key = @domStorage.key i

            match = key.match pattern
            continue unless match

            name = ":#{match[1]}"
            names[name] = true

        result = []
        for own name, ignored of names
            result.push name.substr 1

        process.nextTick ->
            callback null, result

        return null

    #---------------------------------------------------------------------------
    getStorage: (name) ->

        storage = @domStorage.getItem "cloudStorage.#{name}"
        unless storage?
            storage = "{}"
            @_store name, {}

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
        result = []

        for key, val of @storage
            result.push key.substr 1

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    get: (key, callback) ->
        result = @storage[":#{key}"]

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->
        @storage[":#{key}"] = value
        @manager._store @name, @storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    del: (key, callback) ->
        delete @storage[":#{key}"]
        @manager._store @name, @storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    clear: (callback) ->
        @storage = {}
        @manager._store @name, @storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    destroy: (callback) ->
        @storage = {}
        @manager._delete @name

        process.nextTick ->
            callback null if callback?

        return null

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
