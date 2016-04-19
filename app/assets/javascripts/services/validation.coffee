app.service 'validationService', [ ->

  MIN_TEXT_LENGTH = 0
  MAX_TEXT_LENGTH = 1000

  validateText = (text) ->
    result = []
    if text.length not in [MIN_TEXT_LENGTH..MAX_TEXT_LENGTH]
      result.push("Text must be between #{MIN_TEXT_LENGTH} and #{MAX_TEXT_LENGTH} characters long.")
    if text.replace(/[^a-z]+/ig, '').length == 0
      result.push("Text must contain at least one english character.")
    result

  validateShift = (shift) ->
    valid = shift in [0..25]
    if valid then [] else ['Shift must be an integer between 0 and 25']

  validateOperation = (operation) ->
    valid = operation == 'encrypt' or operation == 'decrypt'
    if valid then [] else ['Forbidden operation']

  return {
    validateText:      validateText
    validateShift:     validateShift
    validateOperation: validateOperation
  }
]