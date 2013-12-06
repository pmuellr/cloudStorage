#-------------------------------------------------------------------------------
describe "version", ->

    #----------------------------------
    it "should be a string", ->
        expect(cloudStorage.version).to.match /^\d+\.\d+\.\d+(.*)$/

#-------------------------------------------------------------------------------
runTests = (storageMgr, userid) ->

    #----------------------------------
    before (done) ->
        storageMgr.getStorageNames userid, (err, names) ->
            return done err if err?

            count = names.length
            return done() if count is 0

            index = 0
            for name in names
                storage = storageMgr.getStorage userid, name
                storage.clear (err) ->
                    return done err if err?

                    index++
                    done() if index is count

            return

    #----------------------------------
    it "should have a storageManager", ->
        expect(storageMgr).to.be.an "object"

    #----------------------------------
    it "should have expected user", (done) ->
        storageMgr.getUser (err, user) ->
            return done err if err?

            trycatch done, ->  
                if userid?
                    expect(user.id).to.eql(userid)
                else
                    expect(user).to.eql(userid)

            done()

    #----------------------------------
    it "should have no storage objects", (done) ->
        storageMgr.getStorageNames userid, (err, names) ->
            return done err if err?

            trycatch done, -> expect(names).to.be.empty()

            done()

    #----------------------------------
    it "should be able to create a new storage object", (done) ->
        storage = storageMgr.getStorage userid, "test"

        expect(storage).to.be.an "object"

        storageMgr.getStorageNames userid, (err, names) ->
            done err

    #----------------------------------
    it "should return null for keys not present", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.get "a-key", (err, value) ->
            return done err if err?

            trycatch done, -> expect(value?).to.not.be.ok()

            done()

    #----------------------------------
    it "should add a key/string successfully", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.put "a-key", "a-value", (err) ->
            return done err if err?

            storage.get "a-key", (err, value) ->

                trycatch done, -> expect(value).to.be "a-value"

                done()

    #----------------------------------
    it "should create path-escapble users, storage names and keys", (done) ->

        storage = storageMgr.getStorage "/\//", "/"

        storage.put "::/::", "//://", (err) ->
            return done err if err?

            storage.get "::/::", (err, value) ->

                trycatch done, -> expect(value).to.be "//://"

                done()

    #----------------------------------
    it "should read path-escapble storage names", (done) ->

        storageMgr.getStorageNames "/\//", (err, names) ->
            return done err if err?

            for name in names
                return done() if name is "/"


            trycatch done, -> expect().fail()

            done()

    #----------------------------------
    it "should read path-escapble keys names", (done) ->

        storage = storageMgr.getStorage "/\//", "/"

        storage.keys (err, keys) ->
            return done err if err?

            for key in keys
                return done() if key is "::/::"

            trycatch done, -> expect().fail()

            done()

    #----------------------------------
    it "should add a key/object successfully", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.put "b-key", {b: "value"}, (err) ->
            return done err if err?

            storage.get "b-key", (err, value) ->

                trycatch done, -> expect(value).to.eql {b: "value"}

                done()

    #----------------------------------
    it "should list keys successfully", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.keys (err, keys) ->
            return done err if err?

            trycatch done, -> 
                keys.sort()
                expect(keys).to.have.length 2
                expect(keys[0]).to.be "a-key"  
                expect(keys[1]).to.be "b-key"  

            done()

    #----------------------------------
    it "should delete a key", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.del "b-key", (err) ->
            return done err if err?

            storage.keys (err, keys) ->
                return done err if err?

                trycatch done, -> 
                    expect(keys).to.have.length 1
                    expect(keys[0]).to.be "a-key"  

                done()

    #----------------------------------
    it "should clear all entries", (done) ->

        storage = storageMgr.getStorage userid, "test"

        storage.clear (err) ->
            return done err if err?

            storage.keys (err, keys) ->
                return done err if err?

                trycatch done, -> expect(keys).to.have.length 0

                done()

    #----------------------------------
    it "should handle promises: getUser()", (done) ->
        p = storageMgr.getUser()
        p.then (user) -> 
            trycatch done, ->  
                if userid?
                    expect(user.id).to.eql userid
                else
                    expect(user).to.eql userid
        p.then -> done()
        p.fail done
        return

    #----------------------------------
    it "should handle promises: getStorageNames()", (done) ->
        p = storageMgr.getStorageNames userid

        p.then (names) -> trycatch(done, -> expect(names).to.be.an Array)
        p.then -> done()
        p.fail done
        return

    #----------------------------------
    it "should handle promises: get()/put()", (done) ->
        storage = storageMgr.getStorage userid, "test-promise"

        p0 = storage.put "p", "q"
        p1 = p0.then -> storage.get "p"
        p1.then (value) -> trycatch(done, -> expect(value).to.be "q")
        p1.then -> done()
        p1.fail done
        return

    #----------------------------------
    it "should handle promises: del()", (done) ->
        storage = storageMgr.getStorage userid, "test-promise"

        p0 = storage.del "p"
        p1 = p0.then -> storage.get "p"
        p1.then (value) -> trycatch(done, -> expect(value).to.not.be.ok())
        p1.then -> done()
        p1.fail done
        return

    #----------------------------------
    it "should handle promises: keys()", (done) ->
        storage = storageMgr.getStorage userid, "test-promise"

        p0 = storage.put "p", "q"
        p1 = p0.then -> storage.keys()
        p1.then (keys) -> trycatch(done, -> expect(keys).to.eql ["p"])
        p1.then -> done()
        p1.fail done
        return

    #----------------------------------
    it "should handle promises: clear()", (done) ->
        storage = storageMgr.getStorage userid, "test-promise"

        p0 = storage.clear()
        p1 = p0.then -> storage.keys()
        p1.then (keys) -> trycatch(done, -> expect(keys).to.eql [])
        p1.then -> done()
        p1.fail done
        return

    #----------------------------------
    it "should leave some droppings", (done) ->
        storage = storageMgr.getStorage userid, "test-droppings"
        p0 =            storage.put "a", "1"
        p1 = p0.then -> storage.put "b", "2"
        p2 = p1.then -> storage.put "c", "3"
        p2.then -> done()
        p2.fail done


#-------------------------------------------------------------------------------
trycatch = (done, fn) ->
    try
        fn()
    catch e
        done(e)

#-------------------------------------------------------------------------------
describe "local", ->
    storageManager = cloudStorage.browserStorageManager "local"
    runTests storageManager

#-------------------------------------------------------------------------------
describe "session", ->
    storageManager = cloudStorage.browserStorageManager "session"
    runTests storageManager

#-------------------------------------------------------------------------------
describe "remote - global", ->
    storageManager = cloudStorage.remoteStorageManager "cloudStorage/global"
    runTests storageManager, "anonymous"


