Chart.defaults.global.defaultFontFamily = "'Fira Sans', sans-serif"
Chart.defaults.global.legend.display = false
Chart.defaults.global.elements.line.borderColor = Palette.pick 'qualitative', 1, 0.8
Chart.defaults.global.elements.rectangle.backgroundColor = Palette.pick 'qualitative', 0, 0.8
Chart.defaults.global.elements.point.radius = 6
Chart.defaults.global.elements.point.hoverRadius = 10
Chart.defaults.global.elements.point.borderWidth = 3
Chart.defaults.global.elements.point.backgroundColor = 'rgba(255,255,255,0.8)'
Chart.defaults.global.elements.point.borderColor = 'rgba(0,0,0,0.25)'

Chart.defaults.colors =
  qualitative:
    backgroundColor: Palette.generate 'qualitative', 0.5
  sequential:
    backgroundColor: Palette.generate 'sequential', 0.5
