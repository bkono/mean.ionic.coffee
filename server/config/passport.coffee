logger           = require '../config/logger'
config           = require '../config/config'
mongoose         = require 'mongoose'
BasicStrategy    = require('passport-http').BasicStrategy
FacebookStrategy = require('passport-facebook').Strategy
User             = require("../users/users.model")

module.exports = (passport) ->

  passport.use new BasicStrategy ({}), (username, password, done) ->
    User.findOne { username: username }, (err, user) ->
      if err then return done(err)
      if not user then return done(null, false)
      if not user.authenticate(password) then return done(null, false)
      return done(null, user)

  passport.serializeUser (user, done) ->
    done(null, user)

  passport.deserializeUser (user, done) ->
    done(null, user)

  passport.use new FacebookStrategy({
    clientID:     config.facebook.clientID,
    clientSecret: config.facebook.clientSecret,
    callbackURL:  config.facebook.callbackURL,
    enableProof:  false
  }, (accessToken, refreshToken, profile, done) ->
    User.findOne {'facebook.id': profile.id}, (err, user) ->
      if err then return done(err)
      if user 
        return done(null, user)
      else
        fbInfo = {
          id: profile.id,
          token: accessToken,
          firstName: profile.name.givenName,
          lastName: profile.name.familyName,
          email: profile.emails[0].value
        }
        newUser = new User
          facebook: fbInfo
        newUser.save (err, user) -> 
          if err then return done(err)
          return done(null, user)
  )
