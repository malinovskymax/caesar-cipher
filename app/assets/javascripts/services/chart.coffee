app.service 'chartService', [ ->

  # Chart object.
  characterFrequenciesChart = {
#    type: 'BarChart'
#    type: 'ColumnChart'
#    type: 'ComboChart'
#    type: 'LineChart'
#    type: 'ScatterChart'
#    type: 'Table'
#    type: 'AreaChart'
    type: "ColumnChart"
    data:
      cols: [
        label: "Letter"
        type: "string"
      ,
        label: "Number of occurrences"
        type: "number"
      ]
      rows: [
# Insert rows here.
      ]
    options:
      legend: 'none'
      backgroundColor: '#f5f5f5'
      colors: ['#0059FF']
      displayExactValues: true
      chartArea:
        left: '0%'
        width: '100%'
      vAxis:
        title: 'Number of occurrences'
        gridlines:
          count: 10
      ,
      hAxis:
        title: 'Letter'
  }

  # Cleanup, rebuild and return chart object.
  # Receiving frequencies object {a: 1, c: 4}.
  # Returning full chart object ready for rendering.
  buildCharacterFrequenciesChart = (frequencies) ->
    # Cleanup before redraw.
    characterFrequenciesChart.data.rows = []
    for k, v of frequencies
      pushRowToCharacterFrequenciesChart(k, v)
    # Sort chart rows in ascending order by number of occerences.
    characterFrequenciesChart.data.rows.sort((a, b) -> return if a.c[1].v < b.c[1].v then 1 else -1)
    characterFrequenciesChart

  pushRowToCharacterFrequenciesChart = (char, occurrences) ->
    characterFrequenciesChart.data.rows.push(
      c: [
        # Uppercase looks better
        v: char.toUpperCase()
      ,
        v: occurrences
        f: "#{occurrences}"
      ]
    )

  return {
    buildCharacterFrequenciesChart: buildCharacterFrequenciesChart
  }
]