module Simple

  class Group
  
    class Item

      attr_accessor :json_file
      attr_accessor :id
      attr_accessor :group

      include SetParams

      def dir
        @json_file.dirname
      end

      def files
        dir.glob('*') - [json_file]
      end

      def to_h
        {
          id: id,
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
        id <=> other.id
      end

      def save
        @group.save_item(self)
      end

    end

  end

end