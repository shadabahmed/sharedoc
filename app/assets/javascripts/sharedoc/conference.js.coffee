# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class doc
  id = undefined
  pages = undefined
  currentPage = undefined
  pageCount = undefined
  name = undefined
  @init = (docOptions) ->
    id = docOptions.id
    name = docOptions.name
    pages = docOptions.pages
    currentPage = 1
    pageCount = pages.length
    doc.changePage(currentPage)

    nextPageChange = ->
      doc.changePage(currentPage + 1)

    $(document).bind('doc_next_page', nextPageChange)

    prevPageChange = ->
      doc.changePage(currentPage - 1)

    $(document).bind('doc_prev_page', prevPageChange)

    pageChange = (evt, pageData = {number : 1})->
      doc.changePage(pageData.number)

    $(document).bind('doc_page_change', pageChange)

  @attrs = ->
    {id: id, name: name, pages: pages, currentPage: currentPage, pageCount: pageCount}
  @pageData = ()->
    src: pages[currentPage - 1]
    number: currentPage
  @changePage = (page) ->
    currentPage =  if page > pageCount then 1 else (if pages < 1 then pageCount else page)
    $(document).trigger('doc_page_changed', doc.pageData())

class roster
  users = undefined
  currentUser = undefined
  addUser = (user)->
    users.list[user.id] = user.name

  removeUser = (user)->
    delete users.list[user.id]
    userIndex = users.moderators.indexOf(user.id)
    delete users.moderators[userIndex]

  newUser = (evt, usersData)->
    users = usersData.users
    if(usersData.user.id == currentUser.id)
      $(document).trigger('roster_self_rejoined')
    $(document).trigger('roster_new_user', usersData.user)

  userDisconnected = (evt, usersData)->
    users = usersData.users
    $(document).trigger('roster_user_left', usersData.user)

  @init = (rosterUser)->
    currentUser = rosterUser
    users = {list: {}}
    users.list[currentUser.id] = currentUser.name
    $(document).bind('transport_new_user', newUser)
    $(document).bind('transport_user_left', userDisconnected)

  @update = (confUsers)->
    users = confUsers
  @getUsers = ->
    users
  @newUserJoined = ->

  @getCurrentUser = ->
    {id: currentUser.id, name: users.list[currentUser.id]}

class chat
  messages = undefined
  @init = ->
    messages = []
  @getMessages = ->
    messages

class transport
  socket = undefined
  options = undefined

  connectionChanged = (status)->
    $(document).trigger('transport_connection_changed', {status: status})

  @init = (transportOptions)->
    options = transportOptions

  @connect = ->
    socket = io.connect(options.host)
    socket.on('connect_failed', ->
      connectionChanged('failed')
    )
    socket.on('error', ->
      connectionChanged('error')
    )
    socket.on('connect', ->
      connectionChanged('connected')
    )
    socket.on('disconnect', ->
      connectionChanged('disconnected')
    )

  @join = (joinOptions)->
    socket.on('conf_joined',  (data)->
      $(document).trigger('transport_connection_changed', {status: 'joined', data: data})
    )
    socket.on('conf_new_user', (data)->
      $(document).trigger('transport_new_user', data)
    )
    socket.on('conf_user_left', (data)->
      $(document).trigger('transport_user_left', data)
    )
    socket.emit('conf_join', joinOptions)


class window.conference
  @doc = doc
  @roster = roster
  @chat = chat
  transport = transport
  $(document).bind('transport_connection_changed', (evt, transportData)->
    if(transportData.status == 'connected')
      doc = conference.doc.attrs()
      transport.join({confid : conference.confid, doc: {id: doc.id, currentPage: doc.currentPage}, user: conference.roster.getCurrentUser()})
    else if(transportData.status == 'joined')
      conference.roster.update(transportData.data.users)
      conference.doc.changePage(transportData.data.doc.currentPage)
  )

  @init = (options)->
    @confid = options.confid
    transport.init(options.transport)
    @doc.init(options.doc)
    @roster.init(options.user)
    @chat.init()

  @join = ->
    transport.connect()