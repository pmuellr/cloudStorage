# Licensed under the Apache License. See footer for details.

_ = require "underscore"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerGlobal

    #---------------------------------------------------------------------------
    constructor: ->
        @_storages = {}

    #---------------------------------------------------------------------------
    getUser: (request, callback) ->
        process.nextTick -> 
            callback(null, "global") if callback?

        return null

    #---------------------------------------------------------------------------
    getStorageNames: (request, callback) ->
        names = {}

        for key, ignored of @_storages
            names[":#{key}"] = true

        result = []
        for own name, ignored of names
            result.push name.substr 1

        process.nextTick ->
            callback null, result

        return null

    #---------------------------------------------------------------------------
    keys: (request, name, callback) ->
        result = []
        storage = @_storages[":#{name}"] || {}

        for key, val of storage
            result.push key.substr 1

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    get: (request, name, key, callback) ->
        storage = @_storages[":#{name}"] || {}
        result  = storage[":#{key}"]

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    put: (request, name, key, value, callback) ->
        storage = @_storages[":#{name}"] || {}

        storage[":#{key}"] = value
        @_store name, storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    del: (request, name, key, callback) ->
        storage = @_storages[":#{name}"] || {}

        delete storage[":#{key}"]
        @_store name, storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    clear: (request, name, callback) ->
        @_delete name

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    _delete: (name) ->
        delete @_storages[":#{name}"]

    #---------------------------------------------------------------------------
    _store: (name, storage) ->
        @_storages[":#{name}"] = storage

    #---------------------------------------------------------------------------
    _dumpStorages: (title) ->
        console.log "dumpStorages: #{title}"
        console.log @_storages

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
