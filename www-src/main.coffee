# Licensed under the Apache License. See footer for details.

url   = require "url"
http  = require "http"
https = require "https"

_ = require "underscore"

pkg     = require "./package.json"
builtOn = require "./builtOn.json"

domStorage    = require "./domStorage"
remoteStorage = require "./remoteStorage"

window.cloudStorage = exports

#-------------------------------------------------------------------------------
StorageManagers = {}

#-------------------------------------------------------------------------------
cloudStorage.version = pkg.version

#-------------------------------------------------------------------------------
cloudStorage.getStorageManager = (url) ->
    return StorageManagers[url] if StorageManagers[url]?

    if url is "local"
        storageManager = new domStorage.storageManager window.localStorage
    else if url is "session"
        storageManager = new domStorage.storageManager window.sessionStorage
    else
        storageManager = new remoteStorage.storageManager url

    StorageManagers[url] = storageManager

    return storageManager


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
