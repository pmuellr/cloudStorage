#-------------------------------------------------------------------------------
describe "version", ->

    #----------------------------------
    it "should be a string", ->
        expect(cloudStorage.version).to.match /^\d+\.\d+\.\d+(.*)$/

#-------------------------------------------------------------------------------
runTests = (url, expectedUser) ->

    storageMgr = null

    #----------------------------------
    before (done) ->
        storageMgr = cloudStorage.getStorageManager url

        storageMgr.getStorageNames (err, names) ->
            done err if err?

            count = names.length
            return done() if count is 0

            index = 0
            for name in names
                storage = storageMgr.getStorage name
                storage.clear (err) ->
                    done err if err?

                    index++
                    done() if index is count

            return

    #----------------------------------
    it "should have a storageManager", ->
        expect(storageMgr).to.be.an "object"

    #----------------------------------
    it "should have expected user", (done) ->
        storageMgr.getUser (err, user) ->
            done err if err?

            try 
                expect(user).to.eql(expectedUser)
            catch e
                done e

            done()

    #----------------------------------
    it "should have no storage objects", (done) ->
        storageMgr.getStorageNames (err, names) ->
            done err if err?

            try 
                expect(names).to.be.empty()
            catch e 
                done e

            done()

    #----------------------------------
    it "should be able to create a new storage object", (done) ->
        storage = storageMgr.getStorage "test"

        expect(storage).to.be.an "object"

        storageMgr.getStorageNames (err, names) ->
            done err

    #----------------------------------
    it "should return null for keys not present", (done) ->

        storage = storageMgr.getStorage "test"

        storage.get "a-key", (err, value) ->
            done err if err?

            try 
                expect(value?).to.not.be.ok()
            catch e 
                done e

            done()

    #----------------------------------
    it "should add a key/string successfully", (done) ->

        storage = storageMgr.getStorage "test"

        storage.put "a-key", "a-value", (err) ->
            done err if err?

            storage.get "a-key", (err, value) ->

                try 
                    expect(value).to.be "a-value"
                catch e 
                    done e

                done()

    #----------------------------------
    it "should add a key/object successfully", (done) ->

        storage = storageMgr.getStorage "test"

        storage.put "b-key", {b: "value"}, (err) ->
            done err if err?

            storage.get "b-key", (err, value) ->

                try 
                    expect(value).to.eql {b: "value"}
                catch e 
                    done e

                done()

    #----------------------------------
    it "should list keys successfully", (done) ->

        storage = storageMgr.getStorage "test"

        storage.keys (err, keys) ->
            done err if err?

            try
                keys.sort()
                expect(keys).to.have.length 2
                expect(keys[0]).to.be "a-key"  
                expect(keys[1]).to.be "b-key"  
            catch e
                done e

            done()

    #----------------------------------
    it "should delete a key", (done) ->

        storage = storageMgr.getStorage "test"

        storage.del "b-key", (err) ->
            done err if err?

            storage.keys (err, keys) ->
                done err if err?

                try
                    expect(keys).to.have.length 1
                    expect(keys[0]).to.be "a-key"  
                catch e
                    done e

                done()

    #----------------------------------
    it "should clear all entries", (done) ->

        storage = storageMgr.getStorage "test"

        storage.clear (err) ->
            done err if err?

            storage.keys (err, keys) ->
                done err if err?

                try
                    expect(keys).to.have.length 0
                catch e
                    done e

                done()


#-------------------------------------------------------------------------------
describe "local", ->
    runTests "local"

#-------------------------------------------------------------------------------
describe "session", ->
    runTests "session"

#-------------------------------------------------------------------------------
describe "remote - global", ->
    runTests "cloudStorage/global", "global"


