module SGF

  #Your basic node. It holds information about itself, its parent, and its children.
  class Node

    attr_accessor :parent, :children, :properties

    # Creates a new node. Arguments which can be passed in are:
    # :parent => parent_node (nil by default)
    # :children => [list, of, children] (empty array if nothing is passed)
    # :properties => {hash_of => properties} (empty hash if nothing is passed)
    def initialize args={}
      @parent = args[:parent]
      @children = []
      add_children args[:children] if args[:children]
      @properties = Hash.new
      @properties.merge! args[:properties] if args[:properties]
    end

    #Takes an arbitrary number of child nodes, adds them to the list of children, and make this node their parent.
    def add_children *nodes
      nodes.flatten!
      raise "Non-node child given!" if nodes.any? { |node| node.class != Node }
      nodes.each { |node| node.parent = self }
      @children.concat nodes
    end

    #Takes a hash {identity => property} and adds those to the current node.
    #If a property already exists, it will append to it.
    def add_properties hash
      hash.each do |key, value|
        @properties[key] ||= ""
        @properties[key].concat value
      end
    end

    #Iterate through each child. Yields a child node, if one exists.
    def each_child
      @children.each { |child| yield child }
    end

    #Compare to another node.
    def == other_node
      @properties == other_node.properties
    end

    #Syntactic sugar for node.properties["XX"]
    def [] identity
      identity = identity.to_s
      @properties[identity]
    end

    #Sometimes you think of 'comments' and not of node["C"] or node.properties["C"]
    def comments
      @properties["C"]
    end

    #Sometimes you think of 'comment' and not 'comments'
    alias :comment :comments

    private

    def method_missing method_name, *args
      property = method_name.to_s.upcase
      if property[/(.*?)=$/]
        @properties[$1] = args[0]
      else
        output = @properties[property]
        super(method_name, args) if output.nil?
        output
      end
    end

  end

end