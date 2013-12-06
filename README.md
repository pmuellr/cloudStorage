cloudStorage
================================================================================

cloudStorage is a library for both the browser and the server, which provides
an object which implements an interface similar to the 
[Storage interface of the DOM](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#Storage),
but stores it's items in the cloud.  Wrappers for localStorage and sessionStorage
objects are also provided.

cloudStorage requires authentication, but doesn't provide APIs for authentication;
bring your own.



general structure
================================================================================

cloudStorage manages storage objects.  A storage object is basically a Map or
Dictionary.  It contains a number of key/value pairs, where the keys are 
strings and the values are JSON-able objects.  You can get/set/delete 
key value pairs in the usual way, and you can obtain an array of all 
the keys.  You can also clear all the key/value pairs at once.

There are two flavors of storage objects: browser and remote.

Browser storage objecs map storage objects to a key/value pairs in 
browser-persisted storage, like `window.localStorage` and 
`window.sessionStorage`.

Remote storage objects are stored on a server.  To use a remote storage
object, you will likely have to be "logged in" to the server.  You can
obtain the currently logged in user with the `getUser()` method of the
storage manager.

Storage objects can be obtained from a storage manager.



browser api
================================================================================

After including the `cloudStorage.js` API, you will have a new object
available globally (installed as a property of the `window` object) named
`cloudStorage`.

For all methods which take a callback parameter,
you can instead not pass a callback function, 
in which case a promise will be returned from the method.
When a callback function is passed, null will be returned from the method.

All functions that take callbacks expect the callback to have the signature:

    callback(err, value)

where `err` is an error, in the case of an error, and `value` is the
relevant value of the method.

Promises will resolved with `value`, and be rejected with `err`.



`cloudStorage` properties
--------------------------------------------------------------------------------

The `cloudStorage` object contains the following properties/functions:

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`version` 

string; the [semver](http://semver.org/) version of cloudStorage in use.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`browserStorageManager(type)`

Returns a StorageManager object for the specified browser storage type.

* type - "local" | "session"

This storage manager persists to localStorage and sessionStorage.

The `userid` parameter on the StorageManager methods is ignored.

The user returned from `StorageManager.getUser()` will be null.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`remoteStorageManager(url)` 

* url - url to remoteStorage server

Returns a StorageManager object for the specified userid and url.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



StorageManager objects
--------------------------------------------------------------------------------

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getUser(callback)` 

Return the currently signed in user.

* `callback(err, user)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `user` - the currently logged in user, spec'ed in
      [Passport's User Profile](http://passportjs.org/guide/profile/).

The user object will be null if the user is not logged in, or for storage
managers which don't support users.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getStorageNames(userid, callback)` 

Return the names of the available storage objects.

* `userid` - the userid of the storage objects to be accessed

* `callback(err, names)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `names` - an array of strings

The `userid` parameter is ignored for browser storage managers.

The `userid` does not necessarily have to be the same as the `id` field
of the user object returned by `getUser()`.  `getUser()` returns the 
logged in user; the `userid` parameter specifies the storage objects
to be accessed.  When different, it means the logged in user is attempting
to access storage owned by `userid`.  The storage manager may or may not
allow this access.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getStorage(userid, name)` 

Return a storage object with the specified name.

* `userid` - the userid of the storage objects to be accessed

* `name` - the name of the storage object to access

The `userid` parameter is ignored for browser storage managers.

The `userid` does not necessarily have to be the same as the `id` field
of the user object returned by `getUser()`.  `getUser()` returns the 
logged in user; the `userid` parameter specifies the storage objects
to be accessed.  When different, it means the logged in user is attempting
to access storage owned by `userid`.  The storage manager may or may not
allow this access.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



Storage objects
--------------------------------------------------------------------------------

Storage objects are collections of key/value pairs, where the key is a 
string and the value is a JSON-able object.  

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`get(key, callback)`

Fetches the value associated with the key from the storage object

* `key` - string; any string is valid

* `callback(err, value)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `value` is the value for the specified key

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`put(key, value, callback)`

Sets the value associated with the key in the storage object.

* `key` - string; any string is valid

* `value` - JSONable object

* `callback(err)`
    * `err` - an Error object when an error occurs, or null if no error occurred

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`del(key, callback)`

Deletes the key/value from the storage object.

* `key` - string; any string is valid

* `callback(err)`
    * `err` - an Error object when an error occurs, or null if no error occurred

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`keys(callback)` 

Returns the keys in the storage object.

* `callback(err, keys)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `keys` - an array of keys

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`clear(callback)`

Remove all the items from the storage object.

* `callback(err)`
    * `err` - an Error object when an error occurs, or null if no error occurred

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



Errors
--------------------------------------------------------------------------------

Errors returned in callback will be null when no error occurred, otherwise
they are an instance of Error objects. 



hacking
--------------------------------------------------------------------------------

Run `grunt watch` to run the build workflow such that when a source file
changes, the server will be rebuilt and relaunched.  Run `grunt` with no 
arguments to see the list of tasks available.  You may need to run a `bower`,
`vendor`, etc grunt task before the `watch` task will work.  And obviously
you will need to run `npm install` on a freshly cloned repo to get all
the node dependencies installed.



license
--------------------------------------------------------------------------------

Licensed under [the Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)