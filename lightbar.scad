include<global.scad>
use <./pegmixer.scad>
// use <./pegplate.scad>

PEG_PLATE_W = 30;
PEG_PLATE_H = 35;
PEG_PLATE_THICKNESS = 7;

dioder_end_w_b = 11; //mm
dioder_end_w_t = 9.5; //mm
dioder_end_h = 7.5; //mm

//global variables
STRIP_LENGTH = 250;
CHAINED_STRIPS_COUNT = 1; //number of strips in series, plugged into eacher (effects the length)
PARALLEL_STRIPS_COUNT = 2; //depth of one bracket is 18
BRACKET_PADDING = 7; //From the edge of the light to the edge of the LED bracket
LED_PADDING = 7; //Distance between each LED along the strip
LIGHTBAR_DEPTH = ((LED_PADDING * 2 ) * PARALLEL_STRIPS_COUNT) + (BRACKET_PADDING * 2); //From the wall
LIGHTBAR_HEIGHT = 50; //Height of the lightbar
WALL_THICKNESS = 1;
RIB_THICKNESS = 2;
LIGHTBAR_LENGTH = STRIP_LENGTH * CHAINED_STRIPS_COUNT;
RIB_HEIGHT = dioder_end_h + 5;
RIB_COUNT = 8;

MAX_PRINTER_WIDTH = 300; // for k1se
CLIP_OVERRIDE = true;
CLIPS_ENABLED = LIGHTBAR_LENGTH >= MAX_PRINTER_WIDTH || CLIP_OVERRIDE ? true : false;

DIFFUSER_THICKNESS = 1.5;
DIFFUSER_CLEARANCE = 0.5;   // looseness
DIFFUSER_LIP       = 1.0;   // retention lip
DIFFUSER_SLOT      = DIFFUSER_THICKNESS + DIFFUSER_CLEARANCE;
CHANNEL_DEPTH      = 5;
CHANNEL_HEIGHT     = DIFFUSER_LIP * 2 + DIFFUSER_SLOT +0.1;

front_face_sheer = 10;
slope_angle = atan(front_face_sheer / LIGHTBAR_HEIGHT); // in degrees
top_sheer = RIB_HEIGHT * tan(slope_angle);
diffuser_channel_sheer = CHANNEL_HEIGHT * tan(slope_angle);
front_face_run = tan(slope_angle) * LIGHTBAR_HEIGHT - 5;

// offset 
module dioder_led(
    wt = dioder_end_w_t,
    wb = dioder_end_w_b,
    h = dioder_end_h
) 
{
    xrot(90)
    linear_extrude(STRIP_LENGTH + 2)
    hull() {
        offset([0, 0, 0]) {
            translate([-wt/2, h/2]) square([wt, h/2]);
            translate([-wb/2, 0]) square([wb, h/2]);
        }
    }
}

// full rail
module diffuser_channel(angled_edge) {
    full_depth = LIGHTBAR_DEPTH + front_face_run + WALL_THICKNESS * 2.3 + 0.72;
    diffuser_surface_area = full_depth - CHANNEL_DEPTH -3;

    xrot(90) yrot(90) translate([0,LIGHTBAR_HEIGHT - (DIFFUSER_LIP *2 + DIFFUSER_SLOT) ,0])
    linear_extrude(LIGHTBAR_LENGTH)
        difference(center=true) {
            polygon(points=[
                [0, 0],
                [full_depth, 0],
                [full_depth + diffuser_channel_sheer, CHANNEL_HEIGHT],
                [0, CHANNEL_HEIGHT]
            ]);
            translate([0,DIFFUSER_LIP]) square([full_depth, DIFFUSER_SLOT]);
            translate([CHANNEL_DEPTH / 2 + 2.75, 0]) square([diffuser_surface_area, CHANNEL_HEIGHT]);
        }
}


module rib(x_pos) {
    shear = front_face_sheer;      
    rib_h = RIB_HEIGHT;           
    rib_t = RIB_THICKNESS;         
    depth = LIGHTBAR_DEPTH;
    translate([x_pos, 0, 0])
    zrot(90) xrot(90)
        linear_extrude(height = rib_t)
            polygon(points=[
                [0, 0],             // back bottom
                [depth, 0],         // front bottom
                [depth + top_sheer, rib_h], // front top (sheared)
                [0, rib_h]          // back top
            ]);
}


module ribs() {
    usable_length = LIGHTBAR_LENGTH - WALL_THICKNESS * 2;
    rib_spacing = usable_length / (RIB_COUNT - 1);

    for (i = [0 : RIB_COUNT - 1]) {
        x =
            WALL_THICKNESS
          + i * rib_spacing
          - RIB_THICKNESS / 2;

        rib(x);
    }
}

module brackets() {
    module map_strips(parallel, chain) {
        translate([0,BRACKET_PADDING / 2,0]){
            repeat_axis(parallel, LED_PADDING + dioder_end_w_b, [0,1,0]) { 
                repeat_axis(chain, STRIP_LENGTH + 1, [1,0,0]) { 
                    zrot(90) 
                    translate([dioder_end_w_b/2+LED_PADDING -2,1, RIB_HEIGHT- dioder_end_h]) 
                    dioder_led(); 
                }   
            }
        }
    }

    difference(){
        ribs();
        map_strips(PARALLEL_STRIPS_COUNT, CHAINED_STRIPS_COUNT);
    }
}

module lightbar_frame() {

    module body(){
        cube([LIGHTBAR_LENGTH, WALL_THICKNESS * 2, LIGHTBAR_HEIGHT]);
        cube([LIGHTBAR_LENGTH, LIGHTBAR_DEPTH, WALL_THICKNESS ]);
        translate([0,LIGHTBAR_DEPTH - WALL_THICKNESS,0]) {
            hull() {
                translate([0,+10,LIGHTBAR_HEIGHT]) cube([STRIP_LENGTH * CHAINED_STRIPS_COUNT, WALL_THICKNESS, 0.1]);
                cube([STRIP_LENGTH * CHAINED_STRIPS_COUNT, WALL_THICKNESS, 0.1]);
            }
        }
        brackets();
        diffuser_channel();
    }

    if (CLIPS_ENABLED) {
        difference() {
            union() {
                body();
                clip_solids();
            }
                clip_voids();
        }
    } else body();
}

clip_clearance = 0.5;
clipwall = 1;
clipdepth = 15;

module clip_solids() {
    repeat_axis(PARALLEL_STRIPS_COUNT + 1, LIGHTBAR_DEPTH/ 3 + 0.5, [0,1,0])
    translate([clipdepth/2,5,1.75]) {
        cube(center=true,[clipdepth, 8, 3]);
        translate([LIGHTBAR_LENGTH,0,0]) {
            cube(center=true,[clipdepth - clipwall + clip_clearance, 8 -clipwall + clip_clearance, 3 - clipwall + clip_clearance]);
        }
    }
}


module clip_voids() {
    repeat_axis(PARALLEL_STRIPS_COUNT + 1, LIGHTBAR_DEPTH/ 3 + 0.5, [0,1,0])
    translate([clipdepth/2,5,1.75])
    cube(center=true,[clipdepth + clipwall, 8-clipwall, 3-clipwall]);
}

module peg_plate() {
    pegboard_thickness = 3;
    translate([0,0,PEG_PLATE_H / 2 - 3])
    pegmixer(hole_d = 3, board_thickness = pegboard_thickness, alignment_peg_length=0, arc_d_mul=4) virtual([]);
    cube([PEG_PLATE_W - 1, PEG_PLATE_THICKNESS - 2, PEG_PLATE_H ], center=true);
}

module peg_slot() {
    clearance = 0.2;
    difference(){
        difference(){
            cube([PEG_PLATE_W + 2, PEG_PLATE_THICKNESS + 2, PEG_PLATE_H + 2 ], center=true);
            translate([0,0,-2]) cube([PEG_PLATE_W - 10, PEG_PLATE_THICKNESS +5, PEG_PLATE_H +2 ], center=true);
        }
        translate([0,0,-0.5]) cube([PEG_PLATE_W + clearance, PEG_PLATE_THICKNESS + clearance, PEG_PLATE_H + clearance + 2 ], center=true);
    }
}

// peg_plate();

union() {
    lightbar_frame();
    for (i=[0:CHAINED_STRIPS_COUNT]) {
        repeat_axis(2, (LIGHTBAR_LENGTH / 2) * i, [1,0,0]) {
            translate([STRIP_LENGTH / 4, -PEG_PLATE_THICKNESS +3, LIGHTBAR_HEIGHT / 2])
            xrot(180) peg_slot();
        }
    }
}


