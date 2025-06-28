/*
fan and heater cartridge
hello
*/

// Belfry OpenScad Library v2
include <BOSL2/std.scad>
include <BOSL2/geometry.scad>
include <BOSL2/rounding.scad>
include <BOSL2/shapes3d.scad>

$fn = 50;

/* [box] */
fan_box_inner_w = 55.0;
fan_box_inner_h = 30.0;
fan_box_inner_l = 150.0;
//needs to be thick enough for screws to bite into, or to hold hex nuts
fan_box_bottom_thickness = 1.4;  // [0.4:0.1:2] 
fan_box_wall_thickness = 0.6; // [0.4:0.1:2] 


/* [fan] */
//fan screw offset from centerline
// screw 1 is next to the air outlet
fan_screw_1x=21.5;
fan_screw_1y=17.5;
// screw 2 is behind the air outlet
fan_screw_2x=22.0; // there's a plastic bit that sticks out so this needs a little clearance
fan_screw_2y=20.3;
//fan overall width
fan_overall = 51.0;
fan_screw_diam = 3.6;
//hole on bottom
fan_intake_diam = 45.0;
//fan output for tunnel
fan_output_w = 20.0;
fan_output_h = 15.0;
fan_output_x_from_center = fan_overall/2 - fan_output_w/2;
//todo: align tunnel vertically, then adjust this y-shift
fan_output_y_from_center = 0;
// space between back wall and fan
box_buffer = 3;

/* [heater]  */
heater_tunnel_w = 52;
heater_tunnel_h = 24;

heater_screw_diam = 2.0;
heater_screw_sep = 90.0;

/* air ramp */

//space between fan and tunnel
tunnel_buffer = 1;
// distance between fan output and heater input
ramp_radius = heater_tunnel_h;
ramp_l = ramp_radius * 2;
tunnel_l = fan_box_inner_l - ramp_l - fan_overall - box_buffer - tunnel_buffer;
tunnel_color = "seagreen";

fan_debug_cut=false;
difference(){
    fan_box();

    if(fan_debug_cut)
    debug_cuts();
}

module debug_cuts(){
    arbitrary_gap=5;
    translate([0,-fan_box_inner_l/2+fan_overall+arbitrary_gap,0])
    cuboid([500,500,500], anchor=FRONT);

    arbitrary_gap2=1;
    translate([0,0,fan_box_bottom_thickness+arbitrary_gap2])
    cuboid([500,500,500], anchor=BOTTOM);
}

module fan_box() {

    // box and fan cuts
    color("azure")
    difference() {
        //box
        *
        cuboid(
            [ fan_box_inner_w+fan_box_wall_thickness*2, 
            fan_box_inner_l+fan_box_wall_thickness*2, 
            fan_box_inner_h+fan_box_wall_thickness+fan_box_bottom_thickness ],
            anchor=BOTTOM
        );
        //floor only, box disabled
        cuboid(
            [ fan_box_inner_w+fan_box_wall_thickness*2, 
            fan_box_inner_l+fan_box_wall_thickness*2, 
            fan_box_bottom_thickness ],
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
            translate([fan_screw_1x,fan_screw_1y,0])
            fan_screw_hole();
            //fan_screw_2x
            translate([-fan_screw_2x,-fan_screw_2y,0])
            fan_screw_hole();
            
            //fan intake hole
            *cyl(
                l=fan_box_bottom_thickness*3,
                d=fan_intake_diam,
                anchor=CENTER
            );
        }
        
    }
    
    fan_tunnel();
    
    air_ramp();
}

module air_ramp(){
    // air ramp. Turn air 90deg
    //TODO: try making a warped rect-tube programmatically
    translate([0,fan_box_inner_l/2-ramp_radius,fan_box_bottom_thickness + ramp_radius])
    rotate([0,90,0]) {
        // outer, wider, ramp
        quarter_pipe(r=ramp_radius, h = fan_box_inner_w, wall=fan_box_wall_thickness);

        // lid of ramp tunnel
        translate([-ramp_radius,-ramp_radius,0])
        quarter_pipe(r=ramp_radius, h = fan_box_inner_w, wall=fan_box_wall_thickness);
        
        //endcaps
        //*cyl(h = fan_box_wall_thickness, r = ramp_radius, anchor=CENTER );
    }
    // straight up wall
    translate([0,fan_box_inner_l/2,fan_box_bottom_thickness+ramp_radius])
    cuboid([fan_box_inner_w,fan_box_wall_thickness,ramp_radius], anchor=BOTTOM+FRONT);
}

// widens from the from output size to the heater size
module fan_tunnel(){
    fan_output_from_floor = 2.2;
    tunnel_rounding = 4.0;
    fan_output_y_from_center = -(heater_tunnel_h-fan_output_h)/2+fan_output_from_floor;
    // fan tunnel. Take air from fan to heater
    // aligning this is a little whack
    tunnel_y = -fan_box_inner_l/2 + tunnel_l + fan_overall + box_buffer+tunnel_buffer;
    color(tunnel_color)
    translate([ 0, tunnel_y, heater_tunnel_h/2+fan_box_bottom_thickness+fan_box_wall_thickness ])
    rotate([90,0,0])
    rect_tube(
        isize1=[heater_tunnel_w,heater_tunnel_h], isize2=[fan_output_w,fan_output_h],
        wall=fan_box_wall_thickness, h=tunnel_l,
        shift=[-fan_output_x_from_center, fan_output_y_from_center],
        irounding1=tunnel_rounding, // a little rounding to help bridging
        irounding2=tunnel_rounding/4,
        anchor=BOTTOM // I want to achor by the top for easy alignment, but "shift" moves the top
    );

    // support the underneath of fan tunnel so tunnel attaches to box
    translate([ -fan_output_x_from_center, -fan_box_inner_l/2+fan_overall+box_buffer+tunnel_buffer, fan_box_bottom_thickness + fan_output_from_floor/2 ]) {
        rotate([-90,0,0])
        prismoid(
            size1=[fan_output_w+fan_box_wall_thickness*2,fan_output_from_floor],
            size2=[heater_tunnel_w+fan_box_wall_thickness*2,0],
            h=tunnel_l,
            shift=[fan_output_x_from_center, fan_output_from_floor/2]
        );
    }
}

module quarter_pipe(r = 5, h = 10, wall = 1) {
    difference(){
        tube(h=h, ir = r, wall = wall);
        //remove everything but 1/4 of the tube
        removal_size = (r > h) ? r+0.1 : h+0.1 ;
        cuboid(size = removal_size, anchor=BACK);
        cuboid(size = removal_size, anchor=RIGHT);
    }
}

module fan_screw_hole() {
    cyl(
        l=fan_box_bottom_thickness*3,
        d=fan_screw_diam,
        anchor=CENTER
    );
}