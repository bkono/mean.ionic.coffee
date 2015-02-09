auth     = require '../config/auth'
passport = require("passport")
express  = require 'express'
router   = express.Router()

router.get '/facebook', auth.facebook
router.get '/facebook/callback',
  passport.authenticate 'facebook', {failureRedirect: '/users', successRedirect: '/'}

module.exports = router
