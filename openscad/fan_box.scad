/*
filament dryer lid

*/

// Belfry OpenScad Library v2
include <BOSL2/std.scad>
include <BOSL2/geometry.scad>
include <BOSL2/rounding.scad>
include <BOSL2/shapes3d.scad>

$fn = 50;

fan_box_inner_w = 52.0;
fan_box_inner_h = 17.0;
fan_box_inner_l = 200.0;
//needs to be thick enough for screws to bite into, or to hold hex nuts
fan_box_bottom_thickness = 2.0;
fan_box_wall_thickness = 1.0;

// fan tunnel wall
// this widens to the width of the heater cartridge
//TODO: make this iszie
fan_tunnel_w = 20.0;
fan_tunnel_h = 15.0;

// from center
fan_screw_x=22.5;
fan_screw_y=22.5;
fan_overall = 50.0;
fan_screw_diam = 2.0;
fan_intake_diam = 45.0;
//fan_output_x_from_center = 18;
fan_output_x_from_center = fan_overall/2 - fan_tunnel_w/2;
fan_output_y_from_center = 0;

tunnel_width_start = 20.0;
tunnel_from_edge = 0.9;

heater_screw_diam = 2.0;
heater_screw_sep = 90.0;




fan_box();

module fan_box() {

    // box and fan cuts
    difference() {
        //box
        cuboid(
            [ fan_box_inner_w+fan_box_wall_thickness*2, 
            fan_box_inner_l+fan_box_wall_thickness*2, 
            fan_box_inner_h+fan_box_wall_thickness+fan_box_bottom_thickness ],
            anchor=BOTTOM
        );
        
        //empty the box
        //bottom is thicker for screws to bite into
        translate([0,0,fan_box_bottom_thickness])
        cuboid(
            [ fan_box_inner_w, fan_box_inner_l, 
            fan_box_inner_h+fan_box_wall_thickness*2 ],
            anchor=BOTTOM
        
        );
        
        // fan cuts
        translate([0,-fan_box_inner_l/2+fan_overall/2,fan_box_bottom_thickness]) {
            // fan screw holes
            translate([fan_screw_x,fan_screw_x,0])
            fan_screw_hole();
            translate([-fan_screw_x,-fan_screw_x,0])
            fan_screw_hole();
            
            //fan intake hole
            *cyl(
                l=fan_box_bottom_thickness*3,
                d=fan_intake_diam,
                anchor=CENTER
            );
        }
        
    }
    
    module fan_screw_hole() {
        cyl(
            l=fan_box_bottom_thickness*3,
            d=fan_screw_diam,
            anchor=CENTER
        );
    }
    
    // distance between fan output and heater input
    tunnel_l = 100;
    heater_tunnel_w = 52;
    heater_tunnel_h = 24;
    translate([0,fan_overall,heater_tunnel_h/2])
    rotate([90,0,0])
    rect_tube(
        isize1=[heater_tunnel_w,heater_tunnel_h], isize2=[fan_tunnel_w,fan_tunnel_h],
        wall=fan_box_wall_thickness, h=tunnel_l,
        shift=[-fan_output_x_from_center, fan_output_y_from_center]
        //anchor=FRONT
    );
}