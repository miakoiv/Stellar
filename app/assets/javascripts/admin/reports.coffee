# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$.fn.extend
  revenue_chart: (params = {}) ->
    $canvas = this
    moment.locale '#{I18n.locale}'
    $.ajax
      url: $canvas.data 'source'
      data: params
      dataType: 'json'
    .done (data) =>
      $chart = new Chart $canvas,
        type: 'bar'
        data:
          datasets: [
            {
              yAxisID: 'value'
              label: $canvas.data 'valueLabel'
              data: data.daily_value
              type: 'line'
              cubicInterpolationMode: 'monotone'
              fill: false
            }
            {
              yAxisID: 'items'
              label: $canvas.data 'unitsLabel'
              data: data.daily_units
            }
          ]
        options:
          scales:
            xAxes: [
              {
                type: 'time'
                time: {
                  unit: 'month'
                  displayFormats:
                    week: 'YYYY-W'
                }
                barPercentage: 1.0
                categoryPercentage: 0.9
                gridLines: {display: false}
              }
            ]
            yAxes: [
              {
                id: 'value'
              }
              {
                id: 'items'
                position: 'right'
                ticks:
                  min: 0
                  suggestedMax: data.units_max * 2
                gridLines: {display: false}
              }
            ]
      $canvas.on 'chart:update', (data) ->
        $.ajax
          url: $canvas.data 'source'
          dataType: 'json'
        .done (data) ->
          $chart.data.datasets[0].data = data.daily_value
          $chart.data.datasets[1].data = data.daily_units
          $chart.update()
