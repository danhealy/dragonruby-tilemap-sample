module Tilesets
  # A tileset for the simple-mood tile sheet
  # It's included in DragonRuby GTK Sample 20_roguelike_starting_point_two
  class SimpleMood < Base
    def initialize(file="sprites/simple-mood-16x16.png")
      super(file, 16, 16, 2)

      # You could just register every tile by x/y:
      #
      # 16.times do |y|
      #   16.times do |x|
      #     register_tile("tile_#{x}_#{y}".to_sym, x, y, 1, 1)
      #   end
      # end

      register_tile(:floor_normal, 11, 13, 1, 1)
      register_tile(:floor_textured_1, 0, 11, 1, 1)
      register_tile(:floor_textured_2, 1, 11, 1, 1)
      register_tile(:floor_textured_3, 2, 11, 1, 1)
      register_tile(:floor_textured_4, 0, 0, 1, 1)

      register_tile(:hero_rest_0, 0, 4, 1, 1)
      register_tile(:hero_rest_1, 1, 0, 1, 1)
      register_tile(:hero_rest_2, 2, 0, 1, 1)

      register_tile(:hero_n_0, 14, 1, 1, 1)
      register_tile(:hero_n_1, 8, 1, 1, 1)

      register_tile(:hero_s_0, 15, 1, 1, 1)
      register_tile(:hero_s_1,  9, 1, 1, 1)

      register_tile(:hero_e_0,  0, 1, 1, 1)
      register_tile(:hero_e_1, 10, 1, 1, 1)

      register_tile(:hero_w_0,  1, 1, 1, 1)
      register_tile(:hero_w_1, 11, 1, 1, 1)
    end

    def random_floor
      chance = rand(50) # Increase this number for more normal floors
      case chance
      when 0..3
        "floor_textured_#{chance + 1}".to_sym
      else
        :floor_normal
      end
    end
  end
end
