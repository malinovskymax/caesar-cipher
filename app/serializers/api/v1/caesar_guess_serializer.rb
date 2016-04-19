class Api::V1::CaesarGuessSerializer < ActiveModel::Serializer

  attributes :text, :best_shift, :errors

end
