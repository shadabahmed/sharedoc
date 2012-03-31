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
      conference.broadcast('conf_doc_page_change', currentPage)

    $(document).bind('doc_next_page', nextPageChange)

    prevPageChange = ->
      doc.changePage(currentPage - 1)
      conference.broadcast('conf_doc_page_change', currentPage)

    $(document).bind('doc_prev_page', prevPageChange)

    pageChange = (evt, pageNumber)->
      doc.changePage(pageNumber)

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

  @init = (rosterUser)->
    currentUser = rosterUser
    users = {list: {}}
    users.list[currentUser.id] = currentUser.name
  @updateUsers = (usersList)->
    users = usersList
  @getUsers = ->
    users
  @newUser = (usersData)->
    users = usersData.users
    if(usersData.user.id == currentUser.id)
      $(document).trigger('roster_self_rejoined')
    $(document).trigger('roster_user_joined', usersData.user)

  @userLeft =  (usersData)->
    users = usersData.users
    $(document).trigger('roster_user_left', usersData.user)

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

  @init = (transportOptions)->
    options = transportOptions

  @connect = (connectCallback)->
    socket = io.connect(options.host)
    socket.on('connect_failed', ->
      connectCallback('failed')
    )
    socket.on('error', ->
      connectCallback('error')
    )
    socket.on('connect', ->
      connectCallback('connected')
    )
    socket.on('disconnect', ->
      connectCallback ('disconnected')
    )

  @join = (joinOptions)->
    socket.emit('conf_join', joinOptions)
  @broadcast = (name, data)->
    socket.emit(name, data)
  @subscribe = (name, callback)->
    if name instanceof Object
      for own event_name,callback of name
        callback = name[event_name]
        socket.on(event_name, callback)
    else
      socket.on(name, callback)


class window.conference
  @doc = doc
  @roster = roster
  @chat = chat

  @init = (options)->
    @confid = options.confid
    transport.init(options.transport)
    @doc.init(options.doc)
    @roster.init(options.user)
    @chat.init()

  connectCallback = (status)->
    if(status == 'connected')
      # if connected then subscribe to events and join
      transport.subscribe({
        conf_self_joined: conference.joined
        conf_user_joined: conference.roster.newUser,
        conf_user_left: conference.roster.userLeft,
        conf_doc_page_changed: conference.doc.changePage
      })
      doc = conference.doc.attrs()
      conference.emit('conf_join', {confid : conference.confid, doc: {id: doc.id, currentPage: doc.currentPage},
      user: conference.roster.getCurrentUser()})
    $(document).trigger('transport_connection_changed', {status: status})

  @joined = (joinData)->
    conference.roster.updateUsers(joinData.users)
    conference.doc.changePage(joinData.doc.currentPage)
    $(document).trigger('transport_connection_changed', {status: 'joined'})
    $(document).trigger('conf_self_joined')


  @join = ->
    transport.connect(connectCallback)

  @broadcast = (name,data)->
    transport.broadcast(name, data)
  @emit = @broadcast