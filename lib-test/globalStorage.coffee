# Licensed under the Apache License. See footer for details.

_ = require "underscore"

User = 
    provider:    "globalStorage"
    id:          "anonymous"
    displayName: "<anonymous>"
    photos: [
        value:   "http://commons.wikimedia.org/wiki/File%3AGuy_Fawkes_Mask_Image.jpg"
    ]

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerGlobal

    #---------------------------------------------------------------------------
    constructor: ->
        @_storages = {}

    #---------------------------------------------------------------------------
    getUserID: (request, callback) ->
        process.nextTick -> 
            callback null, User.id

        return

    #---------------------------------------------------------------------------
    getUser: (request, callback) ->
        process.nextTick -> 
            callback null, User

        return

    #---------------------------------------------------------------------------
    getStorageNames: (request, user, callback) ->
        names = {}

        for key, ignored of @_storages
            continue if key[0] isnt ":"
            names[key] = true

        result = []
        for own name, ignored of names
            result.push name.substr 1

        process.nextTick ->
            callback null, result

        console.log "getStorageNames(#{user}) -> #{JSON.stringify(result)}" 

        return null

    #---------------------------------------------------------------------------
    keys: (request, user, name, callback) ->
        result = []
        storage = @_storages[":#{name}"] || {}

        for key, ignored of storage
            continue if key[0] isnt ":"
            result.push key.substr 1

        process.nextTick ->
            callback null, result if callback?

        console.log "keys(#{user},#{name}) -> #{JSON.stringify(result)}" 

        return null

    #---------------------------------------------------------------------------
    get: (request, user, name, key, callback) ->
        storage = @_storages[":#{name}"] || {}
        result  = storage[":#{key}"]

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    put: (request, user, name, key, value, callback) ->
        storage = @_storages[":#{name}"] || {}

        storage[":#{key}"] = value
        @_store name, storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    del: (request, user, name, key, callback) ->
        storage = @_storages[":#{name}"] || {}

        delete storage[":#{key}"]
        @_store name, storage

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    clear: (request, user, name, callback) ->
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
