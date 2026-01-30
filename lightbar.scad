include<global.scad>
// include <BOSL2/std.scad>
  
//The width of the end tapers in at the top by about 1mm, this means the clip/teeth need to account for it.
dioder_end_w_b = 9.7; //mm
dioder_end_w_t = 8.1; //mm
dioder_end_h = 7.4; //mm

//global variables
STRIP_LENGTH = 250;
CHAINED_STRIPS_COUNT = 2; //number of strips in series, plugged into eacher (effects the length)
PARALLEL_STRIPS_COUNT = 2; //depth of one bracket is 18
BRACKET_PADDING = 7; //From the edge of the light to the edge of the LED bracket
LED_PADDING = 7; //Distance between each LED along the strip
LIGHTBAR_DEPTH = LED_PADDING * PARALLEL_STRIPS_COUNT + (BRACKET_PADDING * 2); //From the wall
LIGHTBAR_HEIGHT = 20; //Height of the lightbar
DIFFUSER_THICKNESS = 0.25;
WALL_THICKNESS = 1;
RIB_THICKNESS = 2;
LIGHTBAR_LENGTH = STRIP_LENGTH * CHAINED_STRIPS_COUNT;
RIB_HEIGHT = 5;
RIB_COUNT = 14;

front_face_sheer = 10;
slope_angle = atan(front_face_sheer / LIGHTBAR_HEIGHT); // in degrees
top_sheer = RIB_HEIGHT * tan(slope_angle);

// offset 
module dioder_led(
    wt = dioder_end_w_t,
    wb = dioder_end_w_b,
    h = dioder_end_h
) 
{
    xrot(90)
    linear_extrude(LIGHTBAR_LENGTH)
    hull() {
        offset([0, 0, 0]) {
            translate([-wt/2, h/2]) square([wt, h/2]);
            translate([-wb/2, 0]) square([wb, h/2]);
        }
    }
}


module lightbar_frame() {


    union() {
        cube([LIGHTBAR_LENGTH, WALL_THICKNESS * 2, 20]);
        cube([LIGHTBAR_LENGTH, LIGHTBAR_DEPTH, WALL_THICKNESS ]);
        translate([0,LIGHTBAR_DEPTH - WALL_THICKNESS,0]) {
            // xrot(90) yrot(90)
            // linear_extrude(LIGHTBAR_LENGTH) {
            //     polygon(points=[
            //         [0, 0],
            //         [WALL_THICKNESS, 0],
            //         [WALL_THICKNESS + (WALL_THICKNESS + front_face_sheer), LIGHTBAR_HEIGHT],  // Shear applied
            //         [0.1 + (WALL_THICKNESS + front_face_sheer), LIGHTBAR_HEIGHT],  // Shear applied
            //     ]);
            // }
            hull() {
                translate([0,+10,LIGHTBAR_HEIGHT]) cube([STRIP_LENGTH * CHAINED_STRIPS_COUNT, WALL_THICKNESS, 0.1]);
                cube([STRIP_LENGTH * CHAINED_STRIPS_COUNT, WALL_THICKNESS, 0.1]);
            }
        }
    }
}

lightbar_frame();

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



        


rib(0);



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

ribs();

// ribs();