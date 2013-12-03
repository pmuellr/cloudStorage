https = require "https"

express     = require "express"
querystring = require "querystring"

port     = 4000
audience = "http://localhost:#{port}"

#-------------------------------------------------------------------------------
main = ->
    app = express()
    
    app.use express.urlencoded()
    app.use express.cookieParser()
    app.use express.cookieSession 
        key:    "sessionID"
        secret: "keyboard cat"
    
    app.use express.static __dirname
    
    app.post "/persona-auth/login", (request, response) ->
        response.send("hello world")
    
    app.post "/persona-auth/logout", (request, response) ->
        request.session.destroy()
        response.send status: "OK"
    
    app.listen port

#-------------------------------------------------------------------------------
verifyAssertion = (assertion, audience) ->
    query = querystring.stringify 
        assertion: assertion 
        audience: audience

    headers = 
        "Host":          "verifier.login.persona.org"
        "Content-Type":  "application/x-www-form-urlencoded"
        "Content-Length": query.length
    
    options =
        host:    "verifier.login.persona.org"
        port:    443
        path:    "/verify"
        method:  "POST"
        headers: headers

    vRequest = https.request options, (response) ->
        data = ""
        response.on "data", (chunk) -> data += chunk

        response.on "end", ->
            try
                result = JSON.parse(data)
                if (result.status === "okay")
                    return verified(result)
                else
                    return self.error(new VerificationError(result.reason))
            catch e
                return self.error(e)

        response.on "error", (err) ->
            return self.error(err)
            
    vRequest.end query, "utf8"