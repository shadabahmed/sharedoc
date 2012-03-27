#= require sharedoc
$(document).bind 'slide_change', (evt, slideData)->
  $('#slides img').attr('src', slideData.src)
  $('span#slide-number').text(slideData.number)

$('#slides-buttons #next-slide').click ->
  $(document).trigger('next_slide_change')
$('#slides-buttons #prev-slide').click ->
  $(document).trigger('prev_slide_change')
