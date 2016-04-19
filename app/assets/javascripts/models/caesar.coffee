app.factory 'Caesar', [ 'AppModel', (AppModel) ->

  class Caesar extends AppModel
    reqConfig = {
#      url: '/caesar'
      skipRequestProcessing: true # disable sending request parameters wrapping to root object
      httpConfig:
        headers:
          Accept: 'application/json, api.caesar-cipher.v1'
    }
    @configure(reqConfig)

    @guess = (inputText = '') ->
      @$post('/api/caesar/guess', caesar: { text: inputText }, reqConfig)

    @crypt = (params = {}) ->
      @$post("/api/caesar/#{params.operation}", caesar: params, reqConfig)

]
