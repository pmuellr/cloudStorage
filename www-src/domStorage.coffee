# Licensed under the Apache License. See footer for details.

_ = require "underscore"

#-------------------------------------------------------------------------------
exports.StorageDriver = class DomStorageDriver

    #---------------------------------------------------------------------------
    constructor: (@_domStorage) ->

    #---------------------------------------------------------------------------
    getUser: (callback) ->
        process.nextTick -> callback()
        return

    #---------------------------------------------------------------------------
    getStorageNames: (userid, callback) ->
        forUserid = userid

        names = new Set()
        for i in [0...@_domStorage.length]
            {userid, name, key} = storageKeyParse @_domStorage.key i

            continue unless userid is forUserid

            names.add name

        process.nextTick -> callback null, names.items()
        return

    #---------------------------------------------------------------------------
    keys: (userid, name, callback) ->
        forUserid = userid
        forName   = name

        keys = new Set()
        for i in [0...@_domStorage.length]
            {userid, name, key} = storageKeyParse @_domStorage.key i

            continue unless userid is forUserid
            continue unless name   is forName

            keys.add key

        process.nextTick -> callback null, keys.items()
        return

    #---------------------------------------------------------------------------
    get: (userid, name, key, callback) ->
        skey  = storageKeyGenerate userid, name, key
        value = @_domStorage.getItem skey

        process.nextTick -> callback null, value
        return

    #---------------------------------------------------------------------------
    put: (userid, name, key, value, callback) ->
        skey  = storageKeyGenerate userid, name, key

        @_domStorage.setItem skey, value

        process.nextTick -> callback()
        return

    #---------------------------------------------------------------------------
    del: (userid, name, key, callback) ->
        skey  = storageKeyGenerate userid, name, key
        @_domStorage.removeItem skey

        process.nextTick -> callback()
        return

    #---------------------------------------------------------------------------
    clear: (userid, name, callback) ->
        @keys userid, name, (err, keys) =>
            for key in keys
                skey  = storageKeyGenerate userid, name, key
                @_domStorage.removeItem skey

            callback()

        return

#-------------------------------------------------------------------------------
storageKeyGenerate = (userid, name, key) ->
    "cloudStorage/#{userid}/#{name}/#{key}"

#-------------------------------------------------------------------------------
storageKeyParse = (skey) ->
    userid = null
    name   = null
    key    = null

    match = skey.match /cloudStorage\/(.*?)\/(.*?)\/(.*)/
    return {userid, name, key} unless match?

    userid  = match[1]
    name    = match[2]
    key     = match[3]

    {userid, name, key}

#-------------------------------------------------------------------------------
getInvalidJSONError = ->
    err = new Error message
    err.name = "CloudStorage.InvalidJSON"

    err

#-------------------------------------------------------------------------------
class Set

    #---------------------------------------------------------------------------
    constructor: () ->
        @_keys = {}

    #---------------------------------------------------------------------------
    add: (key) ->
        @_keys[":#{key}"] = true
        return @

    #---------------------------------------------------------------------------
    items: () ->
        result = []
        for own key, ignored of @_keys
            result.push key.substr 1
        result

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
