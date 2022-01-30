module Simple

  class Group
  
    class Item

      attr_accessor :json_file
      attr_accessor :id

      include SetParams

      def dir
        @json_file.dirname
      end

      def to_h
        {
          id: @id,
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end

      def as_json(*options)
        to_h.compact
      end

      def fields(keys)
        keys.map { |k| send(k) }
      end

      def <=>(other)
        @id <=> other.id
      end

    end

  end

end