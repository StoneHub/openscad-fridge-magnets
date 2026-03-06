// Fridge magnet letter tile — fits 100×100 mm build plate
// Render one letter:
//   openscad -q -D 'letter="A"' -o A.stl magnetic_letter_only.scad

// ── Letter ──────────────────────────────────────────────────────────────────
letter    = "M";
size      = 88;   // glyph size in mm — 88 fills most of a 100×100 plate
thickness = 15;   // Z height

// ── Font ────────────────────────────────────────────────────────────────────
// Uncomment one line (or paste any font name from your system):
font_name = "Liberation Sans:style=Bold";
// font_name = "Arial:style=Bold";
// font_name = "Impact";
// font_name = "Courier New:style=Bold";
// font_name = "Comic Sans MS:style=Bold";
// font_name = "Stencil";
// font_name = "Anton";              // narrow + punchy (install from Google Fonts)
// font_name = "Oswald:style=Bold";  // tall + slim  (install from Google Fonts)

// ── Magnet pockets ──────────────────────────────────────────────────────────
magnet_d     = 6.2;  // pocket diameter (slightly loose for 6 mm magnets)
magnet_depth = 2.2;  // pocket depth

// AUTO mode — set true to scatter a grid of pockets across the letter.
//   Any pocket that lands inside a stroke gets cut; pockets in empty space
//   harmlessly cut air and vanish.  Great for finding good spots: render with
//   auto_magnets=true, see which holes appear, then paste those coords into
//   magnet_positions and flip back to false.
auto_magnets      = false;
auto_spacing      = 14;   // mm between grid centres
auto_x_range      = [-40, 40];  // left/right extent to search (mm from centre)
auto_y_range      = [-40, 40];  // bottom/top  extent to search

// MANUAL mode — used when auto_magnets = false.
// Origin [0,0] = visual centre of the glyph (halign/valign = "center").
magnet_positions = [
  [ 17,  15],
  [ 11, -15],
  [-15,  15],
];

// ── Geometry ─────────────────────────────────────────────────────────────────
module letter_body(ch) {
  linear_extrude(height = thickness)
    text(ch, size = size, font = font_name, halign = "center", valign = "center");
}

module pockets() {
  if (auto_magnets) {
    for (x = [auto_x_range[0] : auto_spacing : auto_x_range[1]],
         y = [auto_y_range[0]  : auto_spacing : auto_y_range[1]])
      translate([x, y, 0])
        cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
  } else {
    for (pos = magnet_positions)
      translate([pos[0], pos[1], 0])
        cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
  }
}

difference() {
  letter_body(letter);
  pockets();
}
