$.fn.extend
  modalPosition: ->
    h = $(window).width() - this.width()
    v = $(window).height() - this.height()
    this.css left: 0.8 * h, top: if v > 0 then 0.3 * v else 0
