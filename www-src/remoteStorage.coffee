# Licensed under the Apache License. See footer for details.

url   = require "url"
http  = require "http"
https = require "https"

_ = require "underscore"

#-------------------------------------------------------------------------------
exports.storageManager = class StorageManagerRemote

    #---------------------------------------------------------------------------
    constructor: (@url) ->

    #---------------------------------------------------------------------------
    getUser: -> (callback) ->
        process.nextTick -> 
            callback() if _.isFunction callback

    #---------------------------------------------------------------------------
    getStorageNames: (callback) ->


    #---------------------------------------------------------------------------
    getStorage: (name) ->



#-------------------------------------------------------------------------------
class StorageRemote

    #---------------------------------------------------------------------------
    constructor: (@manager, @name) ->

    #---------------------------------------------------------------------------
    keys: (key, callback) ->

    #---------------------------------------------------------------------------
    get: (key, callback) ->

    #---------------------------------------------------------------------------
    put: (key, value, callback) ->

    #---------------------------------------------------------------------------
    del: (key, callback) ->

    #---------------------------------------------------------------------------
    clear: (callback) ->

    #---------------------------------------------------------------------------
    destroy: (callback) ->
        

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
