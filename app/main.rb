require "app/lib/serializable.rb"
require "app/lib/assignable.rb"
require "app/lib/tilesets/base.rb"
require "app/map.rb"
require "app/camera.rb"
require "app/avatar.rb"

# This is a demonstration of tilemaps, using render_target, camera movement, incremental init (loading bar),
# and an animated avatar
#
# A Game class which sets up a Tileset, Map, Camera and Avatar.
class Game
  include Serializable
  attr_accessor :args, :map, :camera, :tileset, :avatar

  # For init
  attr_accessor :ready, :progress, :finished_at

  def initialize(args)
    @args = args
    @tileset = Tilesets::SimpleMood.new
    @map = Map.new(args)
    @avatar = Avatar.new(args)
    @avatar.assign(@tileset.sprite_for(@avatar.cur_tile))

    @ready = false
    @progress = 0
    @finished_at = (@map.logical_width * @map.logical_height) - 1
    puts "Game#initialize: Initializing #{@map.logical_width}x#{@map.logical_height}=#{@finished_at + 1} Tiles"
    initialize_tiles
  end

  # For loading bar
  def initialization_percent
    (@progress / @finished_at.to_f)
  end

  # If we attempt to initialize the entire map in 1 tick, everything will freeze up until it finishes.
  # So this is a method for loading which is designed to prevent this and allow us to show a loading bar.
  # The idea is that we run this once per tick, several times until initialization is finished.
  def initialize_tiles
    return if @ready

    cur_y, cur_x = @progress.divmod @map.logical_width
    puts "Game#initialize_tiles: #{@progress}/#{@finished_at} = #{(initialization_percent * 100).floor}%"

    start_t = Time.now

    cur_y.upto(@map.logical_height - 1) do |y|
      cur_x.upto(@map.logical_width - 1) do |x|
        cur_tile = @tileset.sprite_for(@tileset.random_floor)

        # Let's give them a little color
        cur_tile.merge!(
          {
            r: rand(35) + 220 * (x / @map.logical_width),
            g: rand(35) + 220 * (y / @map.logical_height),
            b: rand(35) + 220 * (x / @map.logical_width) * (y / @map.logical_height)
          }
        )

        @map.add_tile(x, y, cur_tile)
        @progress += 1

        # Allow this to execute for 8ms (half a tick at 60fps).
        return if (Time.now - start_t) >= 0.008 # rubocop:disable Lint/NonLocalExitFromIterator
      end
      cur_x = 0
    end
    finish_initialization
  end

  def finish_initialization
    @ready = true
    @map.change_tiles(0, 0) # Need to force this to rerender to set up target

    @camera = Camera.new(@map.target_name, @map.target.width, @map.target.height)

    @map.change_tiles(*@camera.pos) # The * splats an array [x,y] into two separate args

    @args.outputs.static_sprites << @camera
    @args.outputs.static_sprites << @avatar
    puts "Game#finish_initialization: Initialized Game"
  end

  # Display the loading bar if we aren't ready
  # Otherwise:
  # - Check the avatar for a frame update
  # - Start the camera following if the avatar is moving
  # - Move the camera to the follow target and reposition avatar
  # - Re-render map based on new camera position
  def tick
    if @ready
      @avatar.assign(@tileset.sprite_for(@avatar.cur_tile)) if @avatar.tick
      @camera.start_following(@avatar) if @avatar.walking
      @avatar.reposition(*@camera.follow)
      @map.change_tiles(*@camera.pos)
    else
      initialize_tiles
      loading_label = {
        x: 640,
        y: 400,
        text: "Reticulating Splines...",
        size_enum: 0,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }
      @args.outputs.background_color = [0, 0, 0]
      @args.outputs.labels  << loading_label
      @args.outputs.solids  << { x: 320, y: 300, w: 640 * initialization_percent, h: 50, r: 0, g: 255, b: 0, a: 255 }
      @args.outputs.borders << { x: 320, y: 300, w: 640, h: 50, r: 255, g: 255, b: 255, a: 255 }
    end

    @args.outputs.background_color = [0, 0, 0]

    @args.outputs.labels << [
      { x: 8, y: 720 - 8,  text: "#{@args.gtk.current_framerate}fps" },
      { x: 8, y: 720 - 88, text: @args.inputs.directional_vector.to_s }
    ]

    if @args.state.game.avatar
      @args.outputs.labels << { x: 8, y: 720 - 48, text: "Avatar: #{@args.state.game.avatar.pos.join('x')}" }
    end

    return unless @args.state.game.camera

    @args.outputs.labels << { x: 8, y: 720 - 68, text: "Camera: #{@args.state.game.camera.pos.join('x')}" }
  end
end

# ----------------------------------------------------------------------------------------------------------------------

def tick(args)
  args.state.game = Game.new(args) if args.tick_count.zero?

  args.state.game.tick
end
