app.service 'analysisService', [ '$window', ($window) ->

  # Count number of occurrences of each english letter, returns object {'a': 2, 'b': 1}.
  getFrequencies = (string) ->
    result = {}
    for i in [0..string.length - 1]
      char = string.charAt(i).toLowerCase()
      # Ignore all non-english-letters symbols
      unless /[a-z]/i.test(char)
        continue
      if result[char]
        result[char]++
      else
        result[char] = 1
    result

  return {
    getFrequencies: getFrequencies
  }
]
