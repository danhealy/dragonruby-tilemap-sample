# The Map defines a very large render_target (w/h larger than the screen),
#   and a tile matrix (3d array) to contain all of the tile sprites
# It also defines #visible_tiles which slices the matrix over the visible portion
#   and returns an array of visible tiles for render
class Map
  include Serializable
  attr_accessor :args, :target, :target_name, :tile_width, :tile_height, :logical_width, :logical_height, :tile_matrix,
                :last_camera, :camera

  # logical_ refers to integer multiples of tiles
  # Setup vars, setup render_target
  def initialize(args, target_name=:map, tile_width=32, tile_height=32, logical_width=200, logical_height=100)
    @args           = args
    @target_name    = target_name
    @tile_width     = tile_width
    @tile_height    = tile_height
    @logical_width  = logical_width
    @logical_height = logical_height

    @tile_matrix = Array.new(logical_height) { Array.new(logical_width) { [] } }

    puts "Map#initialize: Initialized Map which has #{logical_width}x#{logical_height} tiles, " \
         "each tile is #{@tile_width}x#{@tile_height}, " \
         "and the total pixel size is #{@tile_width * @logical_width}x#{@tile_height * @logical_height}"
  end

  # Used for initialization.
  # Expects tile_sprite_attrs to contain necessary variables for a Sprite, except x/y.
  # logical_x/logical_y is the logical position in the tilemap (1,1 is 1 tile in and 1 tile down) FIXME
  # Adds resulting sprite to tile_matrix
  def add_tile(logical_x, logical_y, tile_sprite_attrs)
    tile_sprite = tile_sprite_attrs.merge(x: logical_x * @tile_width, y: logical_y * @tile_height).sprite
    @tile_matrix[logical_y][logical_x] << tile_sprite
  end

  # Convert pixel x/y to logical x/y
  def logical_camera_pos(camera_x, camera_y)
    @camera = [
      (camera_x / @tile_width).floor,
      (camera_y / @tile_height).floor
    ]
  end

  # This returns an enumerator which can be used to iterate over only the tiles which are visible.
  def visible_tiles(logical_x, logical_y)
    max_y = logical_y + (720 / @tile_height).ceil + 1
    max_x = logical_x + (1280 / @tile_width).ceil + 1

    # This enumerator is basically the equivalent of:
    #
    # @tile_matrix[logical_y..max_y].map do |x_tiles|
    #   x_tiles[logical_x..max_x]
    # end.flatten.to_enum
    #
    # The benefit of doing this instead is that we avoid some extraneous iteration and allocation if we call
    # #visible_tiles more than once per tick.  This definitely feels faster, but I haven't benchmarked.

    a = logical_x
    b = logical_y
    Enumerator.new do |yielder|
      loop do
        yielder << @tile_matrix[b][a] if @tile_matrix[b][a]
        r, a = (a + 1).divmod(max_x)
        if r.positive?
          a = logical_x
          b += r
        end
        break unless @tile_matrix[b] && b <= max_y
      end
    end
  end

  # This is just a pass-through to rerender_tiles, but it demonstrates how you could modify tiles already in view
  def change_tiles(camera_x=0, camera_y=0)
    logical_camera_pos(camera_x, camera_y)
    force_rerender = false

    # You could imagine some behavior here that iterates over just the visible tiles and modifies them, such as with an
    # animated tileset.  Anything you'd want to do with tiles that are already on screen.  You'd want to set
    # force_rerender = true if you actually modify something.
    #
    # visible_tiles(*camera).each do |tile|
    #  ...

    rerender_tiles(force_rerender)
  end

  def rerender_tiles(force_rerender=false)
    # Only rerender if the camera has moved out of the previous view
    return unless force_rerender || (@last_camera != @camera)

    # Reinitializes the render_target, erasing what was previously rendered
    @target = @args.render_target(@target_name)

    # We need to tell the render_target about the positional extent of the sprites being assigned to it
    # Otherwise it will default to 1280x720, and if we try to reference outside of that area, it will zoom or fail
    # We could theoretically render all the sprites to the render target, but this takes too much time to do every tick
    # So even though we are only rendering visible_tiles, we are still using the maximum extent of the map, so we can
    # use that in the camera source_x/source_y.
    @target.width  = @tile_width * @logical_width
    @target.height = @tile_height * @logical_height

    # This would also work if we rendered every tile as in @tile_matrix.flatten, but that would take too long.
    @target.static_sprites << visible_tiles(*camera).to_a

    @last_camera = camera
  end
end
