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
fan_box_inner_w = 95.0;
fan_box_inner_h = 40.0;
fan_box_inner_l = 150.0;
//needs to be thick enough for screws to bite into, or to hold hex nuts
fan_box_bottom_thickness = 1.4;  // [0.4:0.1:2] 
fan_box_wall_thickness = 0.6; // [0.4:0.1:2] 
component_gap = 0.4;


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
heater_tunnel_w = 55.5;
heater_tunnel_h = 24;

heater_screw_diam = 3.5;
heater_pin_diam = 3.9;
heater_screw_sep = 83.0;

tunnel_lift = 5.5; // space for frame around heater
post_width=3.24; // center-ish frame piece that I used for measuring ref
right_hole_from_center = 36.0-post_width;
left_hole_from_center = 43.0-post_width;
main_hole_from_side=16.2;
secondary_hole_from_side=10.2;
heater_peg_length = 15.0; // measured 7.75mm from base so make it longer

/* [air ramp] */

//space between fan and tunnel
tunnel_buffer = 1;
// distance between fan output and heater input
ramp_radius = heater_tunnel_h;
ramp_l = ramp_radius * 2;
tunnel_l = fan_box_inner_l - ramp_l - fan_overall - box_buffer - tunnel_buffer;
tunnel_color = "seagreen";


/* [debug] */
fan_debug_cut=false;
box_debug_cut=false;
separate_parts=false;
separate_move = separate_parts?1:0;
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
        if(box_debug_cut) {
            //floor and one side for sideways printing
            translate([-fan_box_wall_thickness,0,0])
            cuboid(
                [ fan_box_inner_w+fan_box_wall_thickness, 
                fan_box_inner_l+fan_box_wall_thickness*2, 
                fan_box_inner_h+fan_box_wall_thickness+fan_box_bottom_thickness ],
                anchor=BOTTOM
            );
        } 
        else {        
            //box
            cuboid(
                [ fan_box_inner_w+fan_box_wall_thickness*2, 
                fan_box_inner_l+fan_box_wall_thickness*2, 
                fan_box_inner_h+fan_box_wall_thickness+fan_box_bottom_thickness ],
                anchor=BOTTOM
            );
        }



        //empty the box
        //bottom is thicker for screws to bite into
        translate([0,0,fan_box_bottom_thickness])
        cuboid(
            [ fan_box_inner_w, fan_box_inner_l, 
            fan_box_inner_h+fan_box_wall_thickness*2 ],
            anchor=BOTTOM
        
        );
        
        // fan cuts
        mirror([1,0,0])
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
        
        translate([0,0,fan_box_inner_h-indent_below_topline])
        locking_recess();
        
    }
    
    translate([separate_parts? -fan_box_inner_w*1.5:0,0,0])
    fan_tunnel();
    
    translate([separate_parts? -fan_box_inner_w*1.5:0,separate_parts?20:0,0])
    air_ramp();
}



module air_ramp(){
    ramp_y=45;
    ramp_fudge=2;
    difference() {
        union(){
            ramp_box();
            
            // heater alignment pin
            translate([0,
                fan_box_inner_l/2-ramp_y,
                fan_box_bottom_thickness + tunnel_lift + heater_tunnel_h/2
            ])
            heater_pins();
        }

        translate([-heater_tunnel_w/2,
            fan_box_inner_l/2-heater_tunnel_h-fan_box_wall_thickness,
            fan_box_bottom_thickness
        ])
        ramp_negative();
        
        // heater screw holes
        translate([0,
            fan_box_inner_l/2-heater_tunnel_h-fan_box_wall_thickness,
            fan_box_bottom_thickness + tunnel_lift + heater_tunnel_h/2
        ])
        heater_screw_holes();
    }

    module ramp_box(){
        //box shape
        translate([0,fan_box_inner_l/2-ramp_y,fan_box_bottom_thickness])
        cuboid([fan_box_inner_w-component_gap*2,ramp_y,fan_box_inner_h], anchor=BOTTOM+FRONT);

        // locking indents
        copy_mirror([1,0,0])
        translate([fan_box_inner_w/2-component_gap,fan_box_inner_l/2-ramp_y/2,fan_box_inner_h-indent_below_topline])
        locking_indent();
    }

    module ramp_negative(){
        // pipe up
        translate([0,heater_tunnel_h,heater_tunnel_w/2-ramp_fudge+tunnel_lift])
        color("red",0.4)
        cuboid(
            [heater_tunnel_w,heater_tunnel_h,heater_tunnel_h*2]
            , anchor=BOTTOM+BACK+LEFT
        );

        // pipe sideways
        color("red",0.4)
        translate([0,0,tunnel_lift])
        cuboid(
            [heater_tunnel_w,heater_tunnel_h*2,heater_tunnel_h]
            , anchor=BOTTOM+BACK+LEFT
        );

        // 90 degree elbow bend
        color("red",0.6)
        translate([0,0,heater_tunnel_h+tunnel_lift])
        rotate([0,90,0])
        rotate_extrude(angle=90, convexity=10)
        square([heater_tunnel_h,heater_tunnel_w]);
    }
    
    
}
module heater_screw_holes(){
    translate([-heater_tunnel_w/2-main_hole_from_side,0,0])
    rotate([90,0,0])
    cyl(d=heater_screw_diam, 
        l=200 //can't be f'd to align it
    );
}
module heater_pins(){
    translate([heater_tunnel_w/2+secondary_hole_from_side,0,0])
    rotate([90,0,0])
    cyl(d1=heater_pin_diam, 
        d2=heater_pin_diam*0.9, //taper 
        l=heater_peg_length
        , anchor=BOTTOM
    );
    // flared base
    translate([heater_tunnel_w/2+secondary_hole_from_side,0,0])
    rotate([90,0,0])
    cyl(d1=heater_pin_diam*2, 
        d2=heater_pin_diam, 
        l=heater_peg_length/4
        , anchor=BOTTOM
    );
    
    
}

// widens from the fan output to the heater
module fan_tunnel(){
fudge=0.5;
    fan_output_from_floor = 2.2;
    tunnel_rounding = 4.0;
    fan_output_y_from_center = -(heater_tunnel_h-fan_output_h)/2+fan_output_from_floor-tunnel_lift;
    // fan tunnel. Take air from fan to heater
    // aligning this is a little whack
    tunnel_y = -fan_box_inner_l/2 + tunnel_l + fan_overall + box_buffer+tunnel_buffer;
    // arch this for printability
    bridge_rounding_out = heater_tunnel_h / 2;
    bridge_rounding_in = fan_output_h / 2;
    
    difference() {
        tunnel_housing();
    
        // air tunnel, expanding from fan size to heater size
        mirror([1,0,0])
        color("red", 0.4)
        translate([ 0, tunnel_y, heater_tunnel_h/2+tunnel_lift+fan_box_bottom_thickness+fan_box_wall_thickness ])
        rotate([90,0,0])
        prismoid(
            size1=[heater_tunnel_w,heater_tunnel_h], 
            size2=[fan_output_w,fan_output_h],
            //wall=fan_box_wall_thickness, 
            h=tunnel_l+fudge,
            shift=[-fan_output_x_from_center, fan_output_y_from_center],
            chamfer1=[bridge_rounding_out,0,0,bridge_rounding_out],
            rounding2=[bridge_rounding_in,tunnel_rounding/4,tunnel_rounding/4,bridge_rounding_in],
            anchor=BOTTOM // I want to achor by the top for easy alignment, but "shift" moves the top
        );
    }
    
    module tunnel_housing() {
        //body
        translate([0,0+tunnel_buffer+box_buffer-fudge,fan_box_bottom_thickness])
        cuboid(
            [fan_box_inner_w-component_gap,tunnel_l-0.01,fan_box_inner_h],
            rounding=fan_box_inner_h/16,
            edges=[BOTTOM+LEFT, BOTTOM+RIGHT],
            anchor=BOTTOM
        );
        
        // locking indents
        copy_mirror([1,0,0])
        translate([fan_box_inner_w/2-component_gap,0,fan_box_inner_h-indent_below_topline])
        locking_indent();
    }


}

indent_depth = 0.6;
//indent_width = 0.4;
indent_length = 2.0;
indent_below_topline = 1.0;
module locking_indent() {
    color("green")
    rotate([90,0,0])
    cyl(l=indent_length, 
        r=indent_depth, 
        rounding=indent_depth/2.1,
        anchor=CENTER
    );
}
module locking_recess(){
    color("red")
    cuboid([fan_box_inner_w+indent_depth,fan_box_inner_l+indent_depth,indent_depth*2],
        rounding=indent_depth,
        anchor=CENTER
    );
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

//copy and mirror an object
module copy_mirror(vec=[0,1,0]){
    children();
    if (vec!=undef && vec!=[0,0,0]) {
        mirror(vec) children();
    }
}