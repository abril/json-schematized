# encoding: UTF-8
module JSON
  module Schematized
    class Base < BasicWrapper.model_superclass
      include Schematized
    end
  end
end
