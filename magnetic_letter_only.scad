// Fridge magnet letter tile — fits 100×100 mm build plate
// Render one letter:
//   openscad -q -D 'letter="A"' -o A.stl magnetic_letter_only.scad

// ── Letter ───────────────────────────────────────────────────────────────────
letter    = "M";
size      = 88;   // glyph size in mm — 88 fills most of a 100×100 plate
thickness = 15;   // Z height

// ── Font ─────────────────────────────────────────────────────────────────────
// Uncomment one line (or paste any font name from your system):
font_name = "Bahnschrift:style=Bold";  // DIN-style, built into Windows 10/11
// font_name = "Bahnschrift:style=Bold Condensed";
// font_name = "Liberation Sans:style=Bold";
// font_name = "Arial:style=Bold";
// font_name = "Impact";
// font_name = "Courier New:style=Bold";
// font_name = "Comic Sans MS:style=Bold";
// font_name = "Anton";               // Google Font — narrow + punchy
// font_name = "Oswald:style=Bold";   // Google Font — tall + slim

// ── Magnet pockets ───────────────────────────────────────────────────────────
magnet_d     = 6.2;  // pocket diameter (slightly loose for 6 mm magnets)
magnet_depth = 2.2;  // pocket depth

// ── AUTO placement ───────────────────────────────────────────────────────────
// The letter shape is used as a mask: candidates that land in empty space are
// clipped to nothing by an intersection() with the letter body and disappear.
// Candidates spiral outward from [0,0] so the best-centered spots are picked
// first. Capped at auto_max_magnets so you never pay for more than you need.
//
// Workflow:
//   1. Set auto_magnets = true, hit F6, see where pockets land.
//   2. Happy with them? Leave auto on — you're done.
//   3. Want exact control? Copy the printed coords into magnet_positions
//      and set auto_magnets = false.
auto_magnets     = false;
auto_max_magnets = 4;   // max pockets — magnets are expensive!
auto_spacing     = 16;  // mm between spiral ring candidates

// ── MANUAL placement ─────────────────────────────────────────────────────────
// Origin [0,0] = visual centre of the glyph.  Add/remove/move entries freely.
magnet_positions = [
  [ 17,  15],
  [ 11, -15],
  [-15,  15],
];

// ── Internals ────────────────────────────────────────────────────────────────

// Spiral candidates: ring 0 = [0,0], ring 1 = 6 pts, ring 2 = 12 pts, ...
// Enumerating inner rings first means the cap always picks central spots.
function _ring(r, sp) =
  r == 0
    ? [[0, 0]]
    : [for (a = [0 : 360 / (r * 6) : 359.9]) [sp * r * cos(a), sp * r * sin(a)]];

function _spiral(sp, rings) =
  [for (r = [0:rings], pt = _ring(r, sp)) pt];

// Build enough candidates that the cap can always find 4 inside any large letter
_candidates = _spiral(auto_spacing, 4);  // 0+6+12+18+24 = 60 candidates

module letter_body() {
  linear_extrude(height = thickness)
    text(letter, size = size, font = font_name, halign = "center", valign = "center");
}

// Letter-masked pocket cylinders: intersection with letter_body() clips any
// cylinder that misses the strokes to empty — no partial ghost holes anywhere.
module auto_pockets() {
  n = min(auto_max_magnets, len(_candidates));
  intersection() {
    // Mask: only keep geometry that overlaps letter material
    linear_extrude(height = magnet_depth)
      text(letter, size = size, font = font_name, halign = "center", valign = "center");
    // Candidates (spiral, capped)
    union()
      for (i = [0 : n - 1])
        translate([_candidates[i][0], _candidates[i][1], 0])
          cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
  }
}

module manual_pockets() {
  for (pos = magnet_positions)
    translate([pos[0], pos[1], 0])
      cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
}

difference() {
  letter_body();
  if (auto_magnets) auto_pockets();
  else              manual_pockets();
}
