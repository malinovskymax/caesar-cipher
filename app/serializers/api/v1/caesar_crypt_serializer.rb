class Api::V1::CaesarCryptSerializer < ActiveModel::Serializer

  attributes :text, :shift, :operation, :errors

end
