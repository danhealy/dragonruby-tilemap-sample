# The Avatar is the player controllable sprite.  It can walk around, has animations, and it'll push the camera if it
# bumps up against the margins.
class Avatar
  include Serializable
  include Assignable
  attr_sprite
  attr_accessor :args, :facing, :walking, :anim_started, :frame

  DIRECTIONS = {
    [ 0,  1] => :n,
    [ 0, -1] => :s,
    [ 1,  0] => :e,
    [-1,  0] => :w,

    [ 0.5,  0.5] => :e,
    [ 0.5, -0.5] => :e,
    [-0.5,  0.5] => :w,
    [-0.5, -0.5] => :w
  }.freeze

  SCREEN_WIDTH  = 1280
  SCREEN_HEIGHT = 720
  TILE_SIZE = 32

  def initialize(args)
    @args = args
    @facing = :s
    stop_walking

    # Initial position
    @x = SCREEN_WIDTH / 2
    @y = SCREEN_HEIGHT / 2

    @velocity_x = 12
    @velocity_y = 12
  end

  # Call this when the animation is restarting
  def reset_frame
    @anim_started = @args.tick_count
    @frame = 0
    true
  end

  def max_frame
    return 2 if @walking

    3
  end

  def frame_speed
    return 15 if @walking

    30
  end

  # For animation, we return true if the frame actually changes
  def next_frame
    if ((@args.tick_count - @anim_started) % frame_speed).zero?
      @frame = (@frame + 1) % max_frame
      return true
    end
    false
  end

  # We return true if the frame actually changes
  # It could return true due to movement starting/stopping/changing direction, or just a new animation frame
  def tick
    update_frame = false
    update_frame = start_walking if !@walking && @args.inputs.directional_vector
    update_frame = stop_walking if @walking && !@args.inputs.directional_vector

    update_frame = true if update_facing

    move if @walking

    update_frame = true if next_frame
    update_frame
  end

  # Pressing the arrow keys causes the directional_vector to change
  # We want to multiply this vector to the velocity and add that to the current position
  # The result needs to be clamped by the screen size
  def move
    camera_bounds = [[0, 0], [SCREEN_WIDTH - TILE_SIZE, SCREEN_HEIGHT - TILE_SIZE]]
    @x = [
      [@x + (@args.inputs.directional_vector[0].round * @velocity_x), camera_bounds[0][0]].max,
      camera_bounds[1][0]
    ].min
    @y = [
      [@y + (@args.inputs.directional_vector[1].round * @velocity_y), camera_bounds[0][1]].max,
      camera_bounds[1][1]
    ].min
  end

  # If the camera is following the avatar, we'll need to move the avatar back by the same magnitude.
  def reposition(x=nil, y=nil)
    return unless x && y

    @x -= x
    @y -= y
  end

  def start_walking
    @walking = true
    reset_frame
  end

  def stop_walking
    @walking = false
    reset_frame
  end

  def update_facing
    new_facing = DIRECTIONS[@args.inputs.directional_vector]
    if new_facing && (new_facing != @facing)
      @facing = new_facing
      return reset_frame
    end

    false
  end

  # By using a naming convention in the tileset, we can generate the proper frame name from attributes here.
  def cur_tile
    if @walking
      "hero_#{@facing}_#{@frame}".to_sym
    else
      "hero_rest_#{@frame}".to_sym
    end
  end

  # Since the tiles are just all white, let's make this guy blue.
  def assign(sprite)
    super(sprite)
    @r = 0
    @g = 0
  end

  def pos
    [@x, @y]
  end
end
