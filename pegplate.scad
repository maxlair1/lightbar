use <./pegmixer.scad>

PEG_PLATE_W = 20;
PEG_PLATE_H = 25;
PEG_PLATE_THICKNESS = 4;

module peg_plate() {
    pegboard_thickness = 3;
    translate([0,0,PEG_PLATE_H / 2 - 3])
    pegmixer(hole_d = 3, board_thickness = pegboard_thickness, alignment_peg_length=0, arc_d_mul=4) virtual([]);
    cube([PEG_PLATE_W, PEG_PLATE_THICKNESS, PEG_PLATE_H ], center=true);
}

peg_plate();