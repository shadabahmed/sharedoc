# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.documents =
  slides: []
  init: (slides) ->
    console.log('inited');  
    this.slides = slides
    this.currentSlide = 0
    this.totalSlides = slides.length
    window.documents.updateSlide()
    $('#slides-buttons #next-slide').click(()->
      window.documents.currentSlide += 1
      window.documents.currentSlide = 0 if window.documents.currentSlide >= window.documents.totalSlides
      window.documents.updateSlide()
    )
    $('#slides-buttons #prev-slide').click(()->
      window.documents.currentSlide -= 1
      window.documents.currentSlide = window.documents.totalSlides - 1 if window.documents.currentSlide < 0
      window.documents.updateSlide()
    )
  updateSlide: (trigger = true) ->
    $('#slides img').attr('src', window.documents.slides[window.documents.currentSlide]) 
    $('span#slide-number').text(window.documents.currentSlide + 1)
    $('#slides-container').trigger('slide-change') if trigger;
  changeSlide: (slide) ->
    window.documents.currentSlide = slide - 1
    window.documents.updateSlide(false)
