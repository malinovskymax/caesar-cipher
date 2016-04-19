class Api::V1::CaesarController < Api::BaseController

  def crypt
    @response = Caesar.new(crypt_params)
    @response.crypt! if @response.valid?
    render json: @response, serializer: Api::V1::CaesarCryptSerializer
  end

  def make_guess
    # .merge(shift: 1) to pass shift validation
    @response = Caesar.new(crypt_params.merge(shift: 1))
    @response.guess_shift_and_decrypt! if @response.valid?
    render json: @response, serializer: Api::V1::CaesarGuessSerializer
  end

  private

  def crypt_params
    params.require(:caesar).permit(:text, :shift, :operation)
  end

end
