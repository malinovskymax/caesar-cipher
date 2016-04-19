app.controller 'index', [ '$scope', 'Caesar', 'analysisService', 'validationService', 'chartService',
  ($scope, Caesar, analysisService, validationService, chartService) ->

    # User's input from textarea
    $scope.inputText = ''
    # Cryptor output (read-only)
    $scope.outputText = ''
    # Input, decrypted with guessed shift
    $scope.guessedText = ''
    $scope.guessedShift = null
    # Initial shift value
    $scope.shift = 0
    # Container for validation errors
    $scope.validation = {}
    # Triggers to show/hide validation errors
    $scope.textInvalid = false
    $scope.shiftInvalid = false
    $scope.operationInvalid = false

    $scope.showGuessMessage = false
    $scope.showChart = false

    # validation
    $scope.validateText = ->
      $scope.validation.text = validationService.validateText($scope.inputText)
      $scope.textInvalid = if $scope.validation.text.length is 0 then false else true

    $scope.validateShift = ->
      $scope.validation.shift = validationService.validateShift($scope.shift)
      $scope.shiftInvalid = if $scope.validation.shift.length is 0 then false else true

    $scope.validateOperation = (operation) ->
      $scope.validation.operation = validationService.validateOperation(operation)
      $scope.operationInvalid = if $scope.validation.operation.length is 0 then false else true


    # Build chart and make guess about shift if analysis say text is encrypted
    $scope.analyzeInput = ->
      $scope.easterTest()
      $scope.validateText()
      if !$scope.textInvalid
        # Frontend say text is valid
        # Show chart
        freq = analysisService.getFrequencies($scope.inputText)
        $scope.characterFrequenciesChart = chartService.buildCharacterFrequenciesChart(freq)
        $scope.showChart = true
        # Analyze and try to guess shift
        Caesar.guess($scope.inputText)
        .then (response) ->
          # Backend responded
          if response.errors.text
            # Backen say text is invalid
            $scope.validation.text = response.errors.text
            $scope.textInvalid = true
          else
            # Backend say text is valid
            return if response.bestShift is 0 # backend say text isn't encrypted
            $scope.showGuessMessage = true
            $scope.guessedText = response.text
            $scope.guessedShift = response.bestShift
        ,(errorResponse) ->
          # Error happen on backend
          #TODO handle errors
          console.log errorResponse
      else
        # Frontend say text is invalid
        # Do not show validation errors if user just clear entire textarea
        if $scope.inputText is ''
          $scope.textInvalid = false
          $scope.validation.text = null
        $scope.showGuessMessage = false
        $scope.showChart = false
        # Free memory
        $scope.characterFrequenciesChart = {}

    # encrypt/decrypt input, receiving string 'encrypt' or 'decrypt'
    $scope.crypt = (operation) ->
      params = { text: $scope.inputText, shift: $scope.shift, operation: operation }
      $scope.validateText()
      $scope.validateShift()
      $scope.validateOperation(operation)
      if not ($scope.textInvalid or $scope.shiftInvalid or $scope.operationInvalid)
        # Frontend say all is valid
        if $scope.shift is 0
          $scope.outputText = $scope.inputText
          return
        Caesar.crypt(params)
        .then (response) ->
          # Backend responded
          for param, errors of response.errors
            $scope.validation[param] = errors
            $scope["#{param}Invalid"] = true
          return if $scope.textInvalid or $scope.shiftInvalid or $scope.operationInvalid # Backen say something is invalid
          else
            # Backend say all is valid
            $scope.outputText = response.text
        ,(errorResponse) ->
          # Error happen on backend
          #TODO handle errors
          console.log errorResponse
      else
        # Frontend say something is invalid
        if $scope.textInvalid
          $scope.outputText = ''
          $scope.showChart = false
          # Free memory
          $scope.characterFrequenciesChart = {}

    $scope.seeGuessed = ->
      $scope.outputText = $scope.guessedText
      $scope.shift = $scope.guessedShift
      $scope.showGuessMessage = false
      # Free memory
      $scope.guessedText = null

    # Easter eggs
    # They always trying it
    $scope.easterTest = ->
      alert 'Test passed, go ahead!' if $scope.inputText.toLowerCase() is 'test'

    # NSA deserves better chances
    creepyAgencyNames = ['NSA', 'NSA', 'CIA', 'KGB', 'MI6', 'Communist Party of China']
    $scope.creepyAgencyName = creepyAgencyNames[Math.floor(Math.random() * creepyAgencyNames.length)]

    slogans = ['have a fun', 'keep it secret', 'never confess', 'get smarter', "don't tell anyone"]
    $scope.slogan = slogans[Math.floor(Math.random() * slogans.length)]

]
