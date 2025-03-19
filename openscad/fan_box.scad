/*
fan and heater cartridge

*/

// Belfry OpenScad Library v2
include <BOSL2/std.scad>
include <BOSL2/geometry.scad>
include <BOSL2/rounding.scad>
include <BOSL2/shapes3d.scad>

$fn = 50;

/* [box] */
fan_box_inner_w = 53.0;
fan_box_inner_h = 17.0;
fan_box_inner_l = 200.0;
//needs to be thick enough for screws to bite into, or to hold hex nuts
fan_box_bottom_thickness = 2.0;
fan_box_wall_thickness = 0.6; //1.0;


/* [fan] */
//fan screw offset from centerline
fan_screw_x=22.5;
fan_screw_y=22.5;
//fan overall width
fan_overall = 50.0;
fan_screw_diam = 3.6;
//hole on bottom
fan_intake_diam = 45.0;
//fan output for tunnel
fan_output_w = 20.0;
fan_output_h = 15.0;
fan_output_x_from_center = fan_overall/2 - fan_output_w/2;
//todo: align tunnel vertically, then adjust this y-shift
fan_output_y_from_center = 0;
box_buffer = 3;
// distance between fan output and heater input
tunnel_l = 100;
tunnel_color = "seagreen";

/* [heater]  */
heater_tunnel_w = 52;
heater_tunnel_h = 24;

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
        translate([0,-fan_box_inner_l/2+fan_overall/2+box_buffer,fan_box_bottom_thickness]) {
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
    
    tunnel_buffer = 1;
    fan_output_from_floor = 2.2;
    fan_output_y_from_center = -(heater_tunnel_h-fan_output_h)/2+fan_output_from_floor;
    // fan tunnel. Take air from fan to heater
    color(tunnel_color)
    translate([0,fan_overall + box_buffer+tunnel_buffer,heater_tunnel_h/2+fan_box_bottom_thickness+fan_box_wall_thickness])
    rotate([90,0,0])
    rect_tube(
        isize1=[heater_tunnel_w,heater_tunnel_h], isize2=[fan_output_w,fan_output_h],
        wall=fan_box_wall_thickness, h=tunnel_l,
        shift=[-fan_output_x_from_center, fan_output_y_from_center]
        //anchor=FRONT
    );
    // fill in the underneath of fan tunnel so tunnel attaches to box
    translate([ -fan_output_x_from_center, -fan_box_inner_l/2+fan_overall+box_buffer+tunnel_buffer, fan_box_bottom_thickness ]) {
        cuboid([ fan_output_w+fan_box_wall_thickness*2, fan_output_w, fan_output_from_floor ], anchor=BOTTOM+FRONT );
    }

}