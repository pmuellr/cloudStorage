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
exports.storageDriver = class GlobalStorageDriver

    #---------------------------------------------------------------------------
    constructor: ->
        @_storages = {}

    #---------------------------------------------------------------------------
    toString: ->
        @constructor.name

    #---------------------------------------------------------------------------
    getUserID: (tx, callback) ->
        process.nextTick -> 
            callback null, User.id

        return

    #---------------------------------------------------------------------------
    getUser: (tx, callback) ->
        process.nextTick -> 
            callback null, User

        return

    #---------------------------------------------------------------------------
    getStorageNames: (tx, user, callback) ->
        names = @_storages[":#{user}"] || {}

        result = []
        for own name, ignored of names
            result.push name.substr 1

        process.nextTick ->
            callback null, result

        return null

    #---------------------------------------------------------------------------
    keys: (tx, user, name, callback) ->
        result = []
        storage = @_getStorage tx, user, name

        for key, ignored of storage
            result.push key.substr 1

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    get: (tx, user, name, key, callback) ->
        storage = @_getStorage tx, user, name
        result  = storage[":#{key}"]

        process.nextTick ->
            callback null, result if callback?

        return null

    #---------------------------------------------------------------------------
    put: (tx, user, name, key, value, callback) ->
        storage = @_getStorage tx, user, name

        storage[":#{key}"] = value

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    del: (tx, user, name, key, callback) ->
        storage = @_getStorage tx, user, name

        delete storage[":#{key}"]

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    clear: (tx, user, name, callback) ->
        uStorage = @_storages[":#{user}"]
        delete uStorage[":#{name}"] if uStorage?

        process.nextTick ->
            callback null if callback?

        return null

    #---------------------------------------------------------------------------
    _getStorage: (tx, user, name) ->
        @_storages[":#{user}"] = {} unless @_storages[":#{user}"]?
        uStorage = @_storages[":#{user}"]

        uStorage[":#{name}"] = {} unless uStorage[":#{name}"]?
        storage = uStorage[":#{name}"]

        return storage

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
