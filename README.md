# Deprecated
Please visit https://github.com/danhealy/dragonruby-zif

# Tilemap Sample

This is a demonstration of tilemaps, using render_target, camera movement, incremental initialization (loading bar), and an animated avatar.  Use the arrow keys, WASD, or your controller to move the avatar around.
- All sprites are defined using Classes except for the debug labels and loading bar
- It uses the simple-mood tileset, 16px x 16px tiles scaled 2x to 32px
- Dynamically generates a map 200 tiles wide by 100 tiles high.
  - Chooses either a blank floor tile, or one of 4 floor textures.  Dynamically applies color to the tile based on X/Y position on the map.
- Tiles are rendered onto a `map` `render_target` infrequently, using `static_sprites`
- The `Camera` uses the `map` `render_target` as a source, and pans around the map by changing `source_x`/`source_y`
- The `Avatar` has standing and walking animation sequences.
- Some reusable components: `Assignable` and `Serializable`


#### Experiment with this code!
Source is under MIT License and available at https://github.com/danhealy/dragonruby-tilemap-sample

Suggested things to try:
- Register more tiles from the tileset in `SimpleMood` and then modify the `random_floor` method to use them
- Use a different tileset, create your own Tileset subclass
- Modify this code to use a pre-generated tile map.  For example, you could generate a JSON file containing x/y positions mapping to the registered sprite name for that position (e.g. `{x: 0, y: 0, tile: "floor_normal"}`).  Then load the JSON using `$gtk.parse_json_file` and iterate
- With some work, you could modify the Avatar code to introduce NPCs.
- You could also try adding objects into the map.  The `Map` `tile_matrix` is a 3D array, just append another sprite to the array.
- Try changing `Camera::FOLLOW_SPEED` and `Avatar#velocity_x` or the Camera easing function

#### Changelog
- September 13 2020: Deprecated in favor of https://github.com/danhealy/dragonruby-zif
- July 25 2020: Updated for DragonRuby GTK version 46.  Removed negative values in `camera.rb` for `source_y`
