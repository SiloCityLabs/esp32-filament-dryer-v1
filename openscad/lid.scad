/*
filament dryer lid

*/

// Belfry OpenScad Library v2
include <BOSL2/std.scad>
include <BOSL2/geometry.scad>
include <BOSL2/rounding.scad>
include <BOSL2/shapes3d.scad>

$fn = 50;

pin_protrusion = 2.0;
pin_diam = 3.5;
pin_rounding = 1.0;
// from top to center of pin
pin_down = 3.9;
pin_skirt_diam = 7.8;
// from center of sealing ring to centerline of pins
lid_length = 42.1;
lid_width = 56.3;
// includes lid thickness
lid_skirt_length = 3.0;
lid_thickness = 1.0;
lid_circle_diam = 70.0;
// out diam that seals into the lid
sealing_ring_diam = 60.0;
sealing_ring_length = 10.5;
sealing_ring_thickness = 1.9;
sealing_ring_taper = 1.1;
hex_width = 78.1;
hex_gap_w = 6.1;
hex_gap_l = 4.2;
hex_octagon_ratio = 3.8; // 4 is an octagon, 0 is a square

lid();


module lid() {


    // square parts of lid
    cuboid( 
        [lid_width, lid_length, lid_thickness],
        anchor=BOTTOM
    );
    // lid skirt
    translate([0,0,-lid_skirt_length]) {
    difference(){
        rect_tube(
            lid_skirt_length, 
            [lid_width,lid_length], 
            [lid_width-lid_thickness*2,lid_length-lid_thickness*2]
        );
        
        // remove extra
        fudge_remove = 31;
        
        translate([0,-lid_length/2+lid_thickness,0])
        cuboid(
            [lid_width+0.1, fudge_remove, lid_skirt_length],
            anchor=BOTTOM
        );
    }

    }
    
    // pins
    copy_mirror([1,0,0])
    translate([lid_width/2, lid_length/2, -pin_down+lid_thickness])
    rotate([0,90,0]) {
        // pin
        cyl(
            l=pin_protrusion, d=pin_diam,
            rounding2=pin_rounding,
            anchor=BOTTOM
        );
        // shroud around pins
        cyl(
            l=lid_thickness, d=pin_skirt_diam,
            anchor=TOP
        );
    }
    
    
    translate([0,-lid_width/2,0]) {
        //tube that goes down
        tube(
            l=sealing_ring_length, 
            od1=sealing_ring_diam-sealing_ring_taper, 
            od2=sealing_ring_diam, 
            wall=sealing_ring_thickness,
            orounding1=sealing_ring_thickness/2,
            anchor=TOP
        );
        
        // hex part of lid
        hex_w = sealing_ring_diam + hex_gap_w*2 + lid_thickness*2;
        hex_l = sealing_ring_diam + hex_gap_l*2 + lid_thickness*2;
        hex_chamfer = ( hex_w > hex_l ? hex_w/hex_octagon_ratio : hex_l/hex_octagon_ratio );
        // hexa lid top
        rect_tube(
            h=lid_skirt_length,
            size=[ hex_w, hex_l],
            wall=lid_thickness,
            chamfer=hex_chamfer,
            anchor=TOP
        );
        cuboid(
            [hex_w, hex_l, lid_thickness],
            chamfer=hex_chamfer,
            edges="Z",
            anchor=BOTTOM
        );
    }
}

/* support functions */

//copy and mirror and object
module copy_mirror(vec=[0,1,0]){
    children();
    mirror(vec) children();
}
