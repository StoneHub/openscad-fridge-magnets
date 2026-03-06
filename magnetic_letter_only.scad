// Fridge magnet letter tile — fits 100×100 mm build plate
// Render:  openscad -q -D 'letter="A"' -o A.stl magnetic_letter_only.scad

// ╔══════════════════════════════════════════════════════════════════╗
// ║  SETTINGS — edit these, leave everything below alone            ║
// ╚══════════════════════════════════════════════════════════════════╝

letter    = "M";
size      = 88;   // glyph height in mm (88 ≈ full 100×100 plate)
thickness = 15;   // Z height of the tile

// ── Font ─────────────────────────────────────────────────────────────────────
font_name = "Bahnschrift:style=Bold";      // DIN-style — built into Win10/11
// font_name = "Bahnschrift:style=Bold Condensed";
// font_name = "Liberation Sans:style=Bold";
// font_name = "Arial:style=Bold";
// font_name = "Impact";
// font_name = "Courier New:style=Bold";
// font_name = "Comic Sans MS:style=Bold";
// font_name = "Anton";                    // Google Font — narrow + punchy
// font_name = "Oswald:style=Bold";        // Google Font — tall + slim

// ── Magnet spec ───────────────────────────────────────────────────────────────
magnet_d     = 6.2;  // pocket diameter  (slightly loose for 6 mm magnets)
magnet_depth = 2.2;  // pocket depth

// ── MODE — uncomment exactly one ─────────────────────────────────────────────
mode = "smart";    // hardcoded per-letter positions for A–Z  (best quality)
// mode = "spiral";  // auto-spiral from centre; only fully-inside pockets kept
// mode = "manual";  // use magnet_positions list below

// ── MANUAL positions (used when mode = "manual") ──────────────────────────────
// Origin [0,0] = visual centre of the glyph.
magnet_positions = [
  [ 17,  15],
  [ 11, -15],
  [-15,  15],
];

// ── SPIRAL settings (used when mode = "spiral") ───────────────────────────────
spiral_max    = 4;   // hard cap — magnets are expensive!
spiral_spacing = 16; // mm between candidate ring steps

// ╔══════════════════════════════════════════════════════════════════╗
// ║  PER-LETTER MAGNET POSITIONS  (mode = "smart")                  ║
// ║  Tuned for Bahnschrift Bold at size = 88.                       ║
// ║  Coords are mm from the visual centre of each glyph.            ║
// ╚══════════════════════════════════════════════════════════════════╝
function letter_magnets(ch) =
  ch == "A" ? [[-18, -22], [ 18, -22], [  0,  -8]             ] :
  ch == "B" ? [[-22,  18], [-22, -15], [ 14,  20], [ 14,  -6] ] :
  ch == "C" ? [[-28,   0], [  0,  25], [  0, -25]             ] :
  ch == "D" ? [[-22,  18], [-22, -18], [ 18,   0]             ] :
  ch == "E" ? [[-22,  22], [-22, -22], [  8,  25], [  8, -25] ] :
  ch == "F" ? [[-22,  20], [-22,  -8], [  8,  25]             ] :
  ch == "G" ? [[-28,   0], [  0,  25], [ 18,  -8]             ] :
  ch == "H" ? [[-22,  15], [-22, -15], [ 22,  15], [ 22, -15] ] :
  ch == "I" ? [[  0,  20], [  0, -20]                         ] :
  ch == "J" ? [[ 14,  22], [ -2, -25]                         ] :
  ch == "K" ? [[-22,  15], [-22, -15], [ 14,  24], [ 14, -24] ] :
  ch == "L" ? [[-22,  18], [-22,  -8], [ 10, -28]             ] :
  ch == "M" ? [[-28,  -5], [-10,  18], [ 10,  18], [ 28,  -5] ] :
  ch == "N" ? [[-22,  15], [-22, -15], [ 22,  15], [ 22, -15] ] :
  ch == "O" ? [[-28,   0], [ 28,   0], [  0,  25], [  0, -25] ] :
  ch == "P" ? [[-22,  15], [-22, -20], [ 14,  18]             ] :
  ch == "Q" ? [[-28,   0], [  0,  25], [ 22, -15]             ] :
  ch == "R" ? [[-22,  15], [-22, -20], [ 14,  18], [ 15, -20] ] :
  ch == "S" ? [[-10,  22], [ 10, -22]                         ] :
  ch == "T" ? [[-24,  28], [ 24,  28], [  0, -10]             ] :
  ch == "U" ? [[-22,  15], [ 22,  15], [  0, -25]             ] :
  ch == "V" ? [[-20,  22], [ 20,  22]                         ] :
  ch == "W" ? [[-28,   5], [-10, -18], [ 10, -18], [ 28,   5] ] :
  ch == "X" ? [[-18,  24], [ 18,  24], [-18, -24], [ 18, -24] ] :
  ch == "Y" ? [[-20,  22], [ 20,  22], [  0, -15]             ] :
  ch == "Z" ? [[  8,  28], [  0,   0], [ -8, -28]             ] :
  /* fallback — centre pocket */ [[0, 0]];

// ╔══════════════════════════════════════════════════════════════════╗
// ║  INTERNALS — nothing to edit below here                         ║
// ╚══════════════════════════════════════════════════════════════════╝

// Spiral candidate list — rings expand outward so the cap always grabs
// the most central (highest-quality) positions first.
function _ring(r, sp) =
  r == 0 ? [[0, 0]]
         : [for (a = [0 : 360 / (r * 6) : 359.9])
              [sp * r * cos(a), sp * r * sin(a)]];

function _spiral_pts(sp, rings) =
  [for (r = [0:rings], pt = _ring(r, sp)) pt];

_candidates = _spiral_pts(spiral_spacing, 4);  // ~60 candidates, inner-first

// ── Geometry modules ─────────────────────────────────────────────────────────

module letter_body() {
  linear_extrude(height = thickness)
    text(letter, size = size, font = font_name,
         halign = "center", valign = "center");
}

// SMART pockets — straight cylinders at the hardcoded positions
module smart_pockets() {
  for (p = letter_magnets(letter))
    translate([p[0], p[1], 0])
      cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
}

// SPIRAL pockets — morphological erosion filter guarantees every pocket
// that survives COMPLETELY fits inside the letter stroke:
//
//   1. Erode letter inward by (magnet_d/2 + margin) using offset().
//      Any centre-point inside the eroded shape is ≥ magnet_d/2 from
//      the letter boundary → the full magnet circle fits.
//   2. Intersect tiny pin-point markers at each spiral candidate with
//      the eroded shape.  Pins outside the eroded zone are clipped away.
//   3. Minkowski-expand the surviving pins by one magnet cylinder →
//      full circular pockets only at geometrically valid positions.
//
module spiral_pockets() {
  n      = min(spiral_max, len(_candidates));
  margin = 0.3;  // extra inset safety margin, mm
  for (i = [0 : n - 1]) {
    cx = _candidates[i][0];
    cy = _candidates[i][1];
    // Process each candidate independently so disconnected survivors
    // don't interfere with each other inside minkowski().
    minkowski() {
      intersection() {
        // Eroded letter mask (very thin slab — just needs to clip the pin)
        linear_extrude(height = 0.02)
          offset(r = -(magnet_d / 2 + margin))
            text(letter, size = size, font = font_name,
                 halign = "center", valign = "center");
        // Tiny pin at this candidate position
        translate([cx, cy, 0])
          cylinder(h = 0.02, r = 0.01, $fn = 4);
      }
      // Expand surviving pin → full magnet pocket
      cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
    }
  }
}

// MANUAL pockets
module manual_pockets() {
  for (p = magnet_positions)
    translate([p[0], p[1], 0])
      cylinder(h = magnet_depth, d = magnet_d, $fn = 64);
}

// ── Main ─────────────────────────────────────────────────────────────────────
difference() {
  letter_body();
  if      (mode == "smart")  smart_pockets();
  else if (mode == "spiral") spiral_pockets();
  else                       manual_pockets();
}
