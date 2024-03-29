require 'json'
require 'path'
require 'set_params'

require 'simple-group/item'

module Simple

  class Group

    class Error < Exception; end

    attr_accessor :root

    InfoFileName = 'info.json'

    def self.item_class
      Item
    end

    def self.search_fields
      []
    end

    def self.convert_id(id)
      id
    end

    def initialize(root:)
      @root = Path.new(root).expand_path
      @items = {}
      if @root.exist?
        @root.glob("*/#{InfoFileName}").each do |info_file|
          raise Error, "Info file does not exist: #{info_file}" unless info_file.exist?
          make_item(**JSON.load(info_file.read))
        end
        # ;;warn "* loaded #{@items.length} items from #{@root}"
      end
    end

    def items
      @items.values
    end

    def convert_id(id)
      self.class.convert_id(id)
    end

    def [](id)
      @items[convert_id(id)]
    end

    def []=(id, value)
      @items[convert_id(id)] = value
    end

    def <<(item)
      item.group = self
      self[item.id] = item
    end

    def make_item(**params)
      item = self.class.item_class.new(**params)
      item.group = self
      item.json_file = json_file_for_id(item.id)
      @items[item.id] = item
      item
    end

    def find(*selectors)
      selectors = [selectors].compact.flatten
      warn "searching #{self.class} for: #{selectors.empty? ? 'ALL' : selectors.join(', ')}"
      if selectors.empty?
        items
      else
        @selected = Set.new
        selectors.each { |s| select(s) }
        @selected.map { |id| self[id] }
      end
    end

    def select(selector)
      case selector.to_s
      when /^:(.*)$/
        select_method($1)
      when /^%(.*)$/
        select_search($1)
      when /^-(.*)$/
        select_remove($1)
      when /^\+?(.*)$/
        select_add($1)
      end
    end

    def select_method(method)
      begin
        @selected += send("#{$1}?").call.map(&:id)
      rescue NameError
        raise Error, "Unknown selector #{selector.inspect} in #{self.class}"
      end
    end

    def select_add(id)
      @selected << convert_id(id)
    end

    def select_remove(id)
      @selected.delete(convert_id(id))
    end

    def select_search(query)
      words = [query].flatten.join(' ').tokenize.sort.uniq - ['-']
      @selected += words.map do |word|
        regexp = Regexp.new(Regexp.quote(word), true)
        @items.values.select do |item|
          self.class.search_fields.find do |field|
            case (value = item.send(field))
            when Array
              value.find { |v| v.to_s =~ regexp }
            else
              value.to_s =~ regexp
            end
          end
        end
      end.flatten.compact.map(&:id)
    end

    def json_file_for_id(id)
      @root / id / InfoFileName
    end

    def save_item(item)
      raise Error, "Item does not have ID" unless item.id
      item.json_file = json_file_for_id(item.id)
      # ;;warn "* saving item to #{item.json_file}"
      json = JSON.pretty_generate(item)
      item.json_file.dirname.mkpath unless item.json_file.dirname.exist?
      item.json_file.write(json)
      self[item.id] ||= item
    end

    def save_hash(hash)
      raise Error, "Hash does not have ID" unless hash[:id]
      json_file = json_file_for_id(hash[:id])
      # ;;warn "* saving item to #{json_file}"
      json = JSON.pretty_generate(hash)
      json_file.dirname.mkpath unless json_file.dirname.exist?
      json_file.write(json)
    end

    def has_item?(id)
      @items.has_key?(convert_id(id))
    end

    def destroy!
      @items = {}
      @root.rmtree if @root.exist?
    end

    def destroy_item!(item)
      @items.delete(item.id)
      dir = json_file_for_id(item.id).dirname
      dir.rmtree if dir.exist?
    end

  end

end