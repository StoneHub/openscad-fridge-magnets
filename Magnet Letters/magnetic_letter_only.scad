// Letter-only magnetic tile (no backing block)
// Example:
// openscad -q -D 'letter="M"' -o M.stl magnetic_letter_only.scad

letter = "M";
font_name = "Liberation Sans:style=Bold";
size = 22;           // overall glyph size
thickness = 15;      // Z height target

// Magnet pockets on backside (z=0 face)
magnet_d = 6.2;
magnet_depth = 2.2;

// Each entry is [x, y] — add, remove, or drag these to taste.
// Origin [0,0] is the visual center of the glyph.
magnet_positions = [
  [-5, -2],
  [ 5, -2],
];

module letter_body(ch) {
  linear_extrude(height = thickness)
    text(ch, size = size, font = font_name, halign = "center", valign = "center");
}

module pockets() {
  for (pos = magnet_positions)
    translate([pos[0], pos[1], 0])
      cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
}

difference() {
  letter_body(letter);
  pockets();
}
