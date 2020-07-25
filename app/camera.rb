# The Camera defines a sprite the size of the window (1280x720) which uses the Map's render_target as the source.
# It's responsible for panning around the Map by modifying the source_x/source_y
class Camera
  include Serializable
  attr_sprite
  attr_accessor :pos_x, :pos_y, :max_x, :max_y, :min_x, :min_y, :velocity_x, :velocity_y, :target_x, :target_y

  SCREEN_WIDTH  = 1280
  SCREEN_HEIGHT = 720

  FOLLOW_SPEED = 30 # frames

  # Setup vars, min/max camera position
  def initialize(targ, target_width, target_height)
    # Position camera covering entire game window exactly
    @x = 0
    @y = 0
    @w = SCREEN_WIDTH
    @h = SCREEN_HEIGHT

    @path = targ

    # Camera views a game-window-sized chunk of target
    @source_x = 0
    @source_y = 0
    @source_w = SCREEN_WIDTH
    @source_h = SCREEN_HEIGHT

    @max_x = target_width - SCREEN_WIDTH
    @max_y = target_height - SCREEN_HEIGHT

    @min_x = 0
    @min_y = 0

    @velocity_x = 0
    @velocity_y = 0

    move(1800, 1200)

    puts "Camera#initialize: Initialized #{@w}x#{@h} Camera looking at '#{targ}' " \
         "which is #{target_width}x#{target_height}, " \
         "starting at #{pos.join('x')}"
  end

  # Changes the source_x/y for the Camera sprite based on the given position, clamped to min/max
  def move(x, y)
    orig_pos_x = @pos_x
    orig_pos_y = @pos_y

    @pos_x = [[x, @min_x].max, @max_x].min
    @pos_y = [[y, @min_y].max, @max_y].min

    # Offset target
    @source_x = @pos_x
    @source_y = @pos_y

    # Return difference
    [@pos_x - orig_pos_x, @pos_y - orig_pos_y]
  end

  # Relative positional change where [1, 1] means add 1 to x/y instead of (1,1)
  # Accepts nil to support behavior of directional_vector
  def move_rel(x=nil, y=nil)
    return unless x && y

    move(@pos_x + x.round, @pos_y + y.round)
  end

  def start_following(sprite)
    # We want to start following the leading sprite if it reaches the margins:
    margin_x = SCREEN_WIDTH / 3
    margin_y = SCREEN_HEIGHT / 2

    @target_x = if sprite.x < margin_x
                  -(margin_x - sprite.x)
                elsif sprite.x > 2 * margin_x
                  sprite.x - 2 * margin_x
                else
                  0
                end

    @target_y = if sprite.y < margin_y
                  -(margin_y - sprite.y)
                elsif sprite.y > margin_y
                  sprite.y - margin_y
                else
                  0
                end

    @follow_count = 0
    @follow_count = FOLLOW_SPEED if @target_x.zero? && @target_y.zero? # Short circuit following if we're at the target
  end

  # Easing function for following.  ease out: sine
  # Returns a value 0.0 -> 1.0 representing percent completion from t based on FOLLOW_SPEED
  def ease(t=@follow_count)
    Math.sin(((t / FOLLOW_SPEED.to_f) * Math::PI) / 2.0)
  end

  # Move the camera towards the target set in #start_following by 1 tick
  def follow
    return if @follow_count.nil? || @follow_count == FOLLOW_SPEED

    # The ease function gives us a percentage, but we need to convert that into an absolute pixel movement for 1 tick
    prev_ease = ease
    @follow_count += 1
    cur_ease = ease

    delta = cur_ease - prev_ease

    move_rel(delta * @target_x, delta * @target_y)
  end

  def pos
    [@pos_x, @pos_y]
  end
end
