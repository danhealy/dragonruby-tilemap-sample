module Tilesets
  # Assigns a tile to a name.  Not a sprite.
  class Tile
    include Serializable
    attr_accessor :name, :x_index, :y_index, :width, :height

    def initialize(name, x_index, y_index, width, height)
      @name      = name
      @x_index   = x_index
      @y_index   = y_index
      @width     = width
      @height    = height
    end
  end
end
