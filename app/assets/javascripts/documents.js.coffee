#= require sharedoc
$(document).bind 'doc_page_changed', (evt, slideData)->
  $('#slides img').attr('src', slideData.src)
  $('span#slide-number').text(slideData.number)

$('#slides-buttons #next-slide').click ->
  $(document).trigger('doc_next_page')
$('#slides-buttons #prev-slide').click ->
  $(document).trigger('doc_prev_change')

$(document).bind('transport_connection_changed', (evt, connectionData)->
  statusLabel = ''
  switch connectionData.status
    when 'failed','error'
      statusLabel = 'label-important'
      statusText = 'Connection failed'
    when 'connected'
      statusLabel = 'label-info'
      statusText = 'Connected'
    when 'joined'
      statusLabel = 'label-success'
      statusText = 'Joined as ' + conference.roster.getCurrentUser().name
    when 'disconnected'
      statusLabel = 'label-warning'
      statusText = 'Disconnected'
  $('div#status_bar span.label').attr('class', 'label ' + statusLabel).text(statusText)
)

$(document).bind('roster_self_rejoined', ->
  $('div#status_bar span.label').text('Joined as ' + conference.roster.getCurrentUser().name)
)

$(document).bind('roster_user_joined', (evt,user)->
  console.log('New users joined' + user.name);
)

$(document).bind('roster_user_left', (evt,user)->
  console.log('User left' + user.name);
)


$(document).bind('roster_user_joined roster_user_left conf_self_joined', (evt,user)->
  users = conference.roster.getUsers()
  $('#roster').html('')
  for own id,name of users.list
    $('#roster').append('<div><span class="label">' + name + '</span></div>')
)