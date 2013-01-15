# encoding: UTF-8
module JSON
  module SchematizedObject
    attr_accessor :__schema__

    def __json__
      self
    end

   protected

    def method_missing(name, *args)
      key = name.to_s
      if key =~ /=\z/
        key = $`.to_sym
        meta = __schema__.member?(key)
        meta ? __schema__.assign!(__json__, key, meta, args.first) : super
      else
        read_attribute key
      end
    end

    def read_attribute(name)
      name = name.to_s
      value = __json__[name]
      if !__json__.has_key?(name) && (meta = __schema__.member?(name))
        case meta[:type]
        when "array"
          value = __json__[name] = [].tap do |array|
            array.extend SchematizedArray
            array.__schema__ = __schema__.class.new(meta[:items])
          end
        when "object"
          value = __json__[name] = {}.tap do |hash|
            hash.extend SchematizedObject
            hash.__schema__ = __schema__.class.new(meta)
          end
        end
      end
      value
    end
  end

  module SchematizedArray
    attr_accessor :__schema__

    def __json__
      self
    end
  end
end
