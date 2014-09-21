Base64 = require 'base64-math'

module.exports =
  FIREBASE_NAME: 'grouped'
  FIREBASE: 'https://grouped.firebaseio.com/'
  TEST_CHILD: 'TEST_CHILD'
  EVENTS_CHILD: 'events'
  PARTICIPANTS_CHILD: 'participants'

  INSERT_OPERATION: 'insert'
  DELETE_OPERATION: 'delete'

  # DOM constants
  DOM_TAGS:
    div:
      html: '<div>'
      length: 1
      container: true
    br:
      html: '<br>'
      length: 1
      container: false
    p:
      html: '<p>'
      length: 1
      container: true
    span:
      html: '<span>'
      length: 0
      container: false
    ul:
      html: '<ul>'
      length: 0
      container: true
    ol:
      html: '<ol>'
      length: 0
      container: true
    li:
      html: '<li>'
      length: 1
      container: true

  TEXT_NODE: 3
  BASE64_ONE: Base64.toBase64(1)