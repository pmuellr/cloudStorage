cloudStorage
================================================================================

cloudStorage is a library for both the browser and the server, which provides
an object which implements an interface similar to the 
[Storage interface of the DOM](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Storage#Storage),
but stores it's items in the cloud.  Wrappers for localStorage and sessionStorage
objects are also provided.

cloudStorage requires authentication, but doesn't provide APIs for authentication;
bring your own.  Requirements on the server are that the request object should
contain a session (in `req.session`) and that the session object should contain
a property `userid`, which is the currently logged in user.



browser api
================================================================================

After including the `cloudStorage.js` API, you will have a new global object
available globally (installed as a property of the `window` object) named
`cloudStorage`.



`cloudStorage` properties
--------------------------------------------------------------------------------

The `cloudStorage` object contains the following properties/functions:

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`version` 

string; the [semver](http://semver.org/) version of cloudStorage in use.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getStorageManager(url)` 

Returns a storage object for the signed in user.

* type - one of "user", "local", or an "http://" or "https://" URL

* name - a string naming this storage object

When type is "local", the storage object is mapped onto window.localStorage.
When type is "session", the storage object is mapped onto window.sessionStorage.
Otherwise the type should be an http:// or https:// URL.



StorageManager objects
--------------------------------------------------------------------------------

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getUser(callback)` 

Return the currently signed in user.

* `callback(err, user)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `user` - the currently logged in user, spec'ed in
      [Passport's User Profile](http://passportjs.org/guide/profile/).


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getStorageNames(callback)` 

Return the names of the available storage objects.

* `callback(err, names)`
    * `err` - an Error object when an error occurs, or null if no error occurred
    * `names` - an array of strings


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

`getStorage(name)` 

Return a storage object with the specified name.

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

`destroy(callback)`

Remove the Store object.

* `callback(err)`
    * `err` - an Error object when an error occurs, or null if no error occurred

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 



Errors
--------------------------------------------------------------------------------

Errors returned in callback will be null when no error occurred, otherwise
they are an instance of Error objects.  The following values will be 
available in the `name` property.

`notAuthenticated`
`notAuthorized`
`notConnected`



hacking
--------------------------------------------------------------------------------

Run `grunt watch` to run the build workflow such that when a source file
changes, the server will be rebuilt and relaunched.  Run `grunt` with no 
arguments to see the list of tasks available.



license
--------------------------------------------------------------------------------

Licensed under [the Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)