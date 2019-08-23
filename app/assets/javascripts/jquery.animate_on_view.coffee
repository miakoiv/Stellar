$.fn.extend
  animateOnView: (selector) ->
    elements = document.querySelectorAll selector
    observer = new IntersectionObserver(
      (entries, observer) =>
        for hit in entries
          continue if not hit.isIntersecting
          e = hit.target
          observer.unobserve e
          e.style.opacity = 1
          e.classList.add 'animated', e.dataset.animation
    , threshold: [0.5])
    for e in elements
      e.style.opacity = 0
      observer.observe e

jQuery ->
  $(document).animateOnView '.animation'
