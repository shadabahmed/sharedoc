# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class doc
  slides = undefined
  currentSlide = undefined
  totalSlides = undefined
  name = undefined
  @init = (docOptions) ->
    name = docOptions.name
    slides = docOptions.slides
    currentSlide = 0
    totalSlides = slides.length
    @updateSlide();
    nextSlideChange = ->
      doc.changeSlide(currentSlide + 2)

    $(document).bind('next_slide_change', nextSlideChange)

    prevSlideChange = ->
      doc.changeSlide(currentSlide)

    $(document).bind('prev_slide_change', prevSlideChange)

    slideChange = (evt, slideData = {number : 1})->
      doc.changeSlide(slideData.number)

    $(document).bind('slide_number_change', slideChange)
  @attrs = ->
    {name: name, slides: slides, currentSlide: currentSlide + 1, totalSlides: totalSlides}
  @updateSlide = ->
    $(document).trigger('slide_change', @slideData())
    null
  @slideData = ()->
    src: slides[currentSlide]
    number: currentSlide + 1
  @changeSlide = (slide) ->
    currentSlide = slide - 1
    currentSlide = 0 if currentSlide >= totalSlides
    currentSlide = totalSlides - 1 if currentSlide < 0
    @updateSlide()

class roster
  users = undefined
  currentUser = undefined
  @init = (rosterUser)->
    users = []
    currentUser = rosterUser

class chat
  messages = undefined
  @init = ->
    messages = []
  @getMessages = ->
    messages

class transport
  host = undefined
  socket = undefined
  @init = (transportOptions)->
    host = transportOptions.host
    socket = io.connect(host);
  @join = ->
    #socket.emit('join', {documentid : <%= @document.id %>, currentslide : window.documents.currentSlide, username : name, userid : '<%= Time.now.utc.to_i %>', moderator: true});

class window.conference
  @doc = doc
  @roster = roster
  @chat = chat
  transport = transport
  @init = (options)->
    @doc.init(options.document)
    transport.init(options.transport)
    @roster.init(options.roster)
    @chat.init()



