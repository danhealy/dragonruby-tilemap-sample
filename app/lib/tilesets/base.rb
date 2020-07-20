require "app/lib/tilesets/tile.rb"
require "app/lib/tilesets/simple_mood.rb"

module Tilesets
  # Base class for tilesets.  Handles registering tiles by name, and generating sprite attrs by name
  class Base
    include Serializable
    attr_accessor :file, :tiles, :base_width, :base_height, :scale_factor

    def initialize(file, base_width=16, base_height=16, scale_factor=1)
      @file = file
      @tiles = {}
      @base_width = base_width
      @base_height = base_height
      @scale_factor = scale_factor
    end

    def register_tile(name, x_index, y_index, width, height)
      @tiles[name] = Tile.new(name, x_index, y_index, width, height)
    end

    def sprite_for(tile)
      raise_unless tile
      {
        w: @tiles[tile].width * @base_width * @scale_factor,
        h: @tiles[tile].height * @base_height * @scale_factor,
        path: @file,
        angle: 0,
        a: 255,
        r: 255,
        g: 255,
        b: 255,
        tile_x: @tiles[tile].x_index * @base_width,
        tile_y: @tiles[tile].y_index * @base_height,
        tile_w: @tiles[tile].width * @base_width,
        tile_h: @tiles[tile].height * @base_height
      }
    end

    private

    def raise_unless(tile)
      raise "Unregistered sprite #{tile}" unless @tiles[tile]
    end
  end
end
