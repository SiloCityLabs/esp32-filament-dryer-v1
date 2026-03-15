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
fan_box_inner_l = 160.0;
//needs to be thick enough for screws to bite into, or to hold hex nuts
fan_box_bottom_thickness = 1.4;  // [0.4:0.1:2] 
fan_box_wall_thickness = 1.0; // [0.4:0.1:2] 
component_gap = 0.4;  // [0.0:0.1:0.8] 


indent_depth = 0.8;
indent_length = 6.0;
indent_below_topline = 3.0;

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
//hole on bottom
fan_intake_diam = 45.0;
//fan output for tunnel
fan_output_w = 20.0;
fan_output_h = 15.0;
// tune horizontal alignment of the fan hole
fan_shift_x=-20;
fan_output_x_from_center = fan_overall/2 - fan_output_w/2 + fan_shift_x;
// tune vertical alignment of the fan hole
fan_output_from_floor = 2.7;
// space between back wall and fan
box_buffer = 3;

fan_screw_diam = 3.6;
fan_screw_post_length = 4.2;

/* [heater]  */
heater_tunnel_w = 55.5;
heater_tunnel_h = 24;

heater_screw_diam = 3.5;
heater_pin_diam = 3.9;
heater_screw_sep = 83.0; // size ref
heater_thickness = 24.2; // size ref

heater_x_offset = 2.5;
heater_cable_r=3;

tunnel_lift = 5.5; // space for frame around heater
main_hole_from_side=16.2;
secondary_hole_from_side=10.2;
heater_peg_length = 15.0; // measured 7.75mm from base so make it longer

/* [air ramp] */

//space between fan and tunnel
tunnel_buffer = 1;
// distance between fan output and heater input
ramp_radius = heater_tunnel_h;
ramp_l = ramp_radius * 2;
tunnel_l = 30;
// aligning this tunnel is a little whack
tunnel_y = -fan_box_inner_l/2 + tunnel_l/2 + fan_overall + box_buffer+tunnel_buffer;
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

    // box and some cutouts
    color("azure")
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
        
        translate([0,0,fan_box_inner_h-indent_below_topline])
        locking_recess();
    }
    
    
    difference(){
        union(){
            // screw posts
            mirror([1,0,0])
            translate([-fan_shift_x,-fan_box_inner_l/2+fan_overall/2+box_buffer,fan_box_bottom_thickness]){
                translate([fan_screw_1x,fan_screw_1y,0])
                fan_screw_post();
                translate([-fan_screw_2x,-fan_screw_2y,0])
                fan_screw_post();
            }
        
        }
        
        // fan cuts
        mirror([1,0,0])
        translate([-fan_shift_x,-fan_box_inner_l/2+fan_overall/2+box_buffer,fan_box_bottom_thickness]) {
            // fan screw holes
            translate([fan_screw_1x,fan_screw_1y,0])
            fan_screw_hole();
            //fan_screw_2x
            translate([-fan_screw_2x,-fan_screw_2y,0])
            fan_screw_hole();
        }
    }
    
    translate([separate_parts? -fan_box_inner_w*1.5:0, tunnel_y ,0])
    fan_tunnel();
    

    
    translate([separate_parts? -fan_box_inner_w*1.5:0,separate_parts?20:0,0])
    air_ramp();
    translate([fan_box_inner_w/2-alignment_pin_d*2,-tunnel_l/2+alignment_pin_d,fan_box_bottom_thickness-0.05])
    alignment_pin();

    
    translate([fan_box_inner_w/2-alignment_pin_d*2,
    fan_box_inner_l/2-heater_tunnel_h,
    fan_box_bottom_thickness-0.05])
    alignment_pin();
        
}



module air_ramp(){
    ramp_y=30;
    ramp_fudge=1;
        
    difference() {
        ramp_box();
        
        translate([-heater_tunnel_w/2,
            fan_box_inner_l/2-heater_tunnel_h-fan_box_wall_thickness,
            fan_box_bottom_thickness
        ])
        ramp_negative();
        
        translate([fan_box_inner_w/2-alignment_pin_d*2,
            fan_box_inner_l/2-heater_tunnel_h,
            fan_box_bottom_thickness-0.05])
        scale([1.10, 1.05, 1.10])
        alignment_pin();
        
        
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
        translate([0,heater_tunnel_h,heater_tunnel_w/2+ramp_fudge]) // not perfect
        color("red",0.4)
        cuboid(
            [heater_tunnel_w,heater_tunnel_h,heater_tunnel_h*2]
            , anchor=BOTTOM+BACK+LEFT
        );

        // pipe sideways
        color("red",0.4)
        translate([0,0,tunnel_lift])
        rotate([90,0,0])
        prismoid(
            size1=[heater_tunnel_w,heater_tunnel_h], 
            size2=[heater_tunnel_w,heater_tunnel_h],
            //wall=fan_box_wall_thickness, 
            h=ramp_y-heater_tunnel_h,
            shift=[heater_x_offset, 0],
            anchor=FRONT+BOTTOM+LEFT
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
    rotate([-90,0,0])
    cyl(d1=heater_pin_diam, 
        d2=heater_pin_diam*0.9, //taper 
        l=heater_peg_length
        , anchor=BOTTOM
    );
    // flared base
    translate([heater_tunnel_w/2+secondary_hole_from_side,0,0])
    rotate([-90,0,0])
    cyl(d1=heater_pin_diam*2, 
        d2=heater_pin_diam, 
        l=heater_peg_length/4
        , anchor=BOTTOM
    );
}
module heater_ledge(){

    block_blah = 7.8;
    tab_height=4.1;
    tab_overhang=2.6;
    translate([heater_tunnel_w/2+secondary_hole_from_side,0,0])
    cuboid([block_blah,tab_height,block_blah],anchor=FRONT);
*    
    translate([heater_tunnel_w/2+secondary_hole_from_side-tab_overhang,tab_height,0])
    cuboid([block_blah,tab_height,block_blah/2],anchor=FRONT);
    
    // goofy, trying to avoid 90 deg overhang
    translate([heater_tunnel_w/2+secondary_hole_from_side-tab_overhang/2,tab_height/3,0])
    rotate([90,0,0])
    prismoid(size1=[block_blah+tab_overhang,block_blah/2], size2=[block_blah/2,block_blah/2], h=tab_height, anchor=TOP);
}


// widens from the fan output to the heater
// comes with alignment pin
module fan_tunnel(){
fudge=0.5;
    tunnel_rounding = 4.0;
    fan_output_y_from_center = -(heater_tunnel_h-fan_output_h)/2+fan_output_from_floor-tunnel_lift;
    
    // arch this for printability
    bridge_rounding_out = heater_tunnel_h / 2;
    bridge_rounding_in = fan_output_h / 2;
    
    difference() {
        union(){
            tunnel_housing();
            
            // heater alignment pin
            *
            translate([heater_x_offset,
                tunnel_l/2-0.1,
                fan_box_bottom_thickness + tunnel_lift + heater_tunnel_h/2
            ])
            heater_pins();
            
            translate([heater_x_offset,
                tunnel_l/2-0.1,
                fan_box_bottom_thickness + tunnel_lift + heater_tunnel_h/2
            ])
            heater_ledge();
        }
        
        // main air tunnel
        tunnel_cut();
        
        // heater screw holes
        translate([heater_x_offset,
            0,
            fan_box_bottom_thickness + tunnel_lift + heater_tunnel_h/2
        ])
        heater_screw_holes();
        
        // slots for heater cables
        translate([-fan_box_inner_w/2+component_gap,0,fan_box_inner_h/4])
        rotate([90,0,0])
        cyl(r=heater_cable_r,l=tunnel_l*2);
        
        translate([-fan_box_inner_w/2+component_gap,0,fan_box_inner_h/1.3])
        rotate([90,0,0])
        cyl(r=heater_cable_r,l=tunnel_l*2);
        
        translate([fan_box_inner_w/2-alignment_pin_d*2,-tunnel_l/2+alignment_pin_d,fan_box_bottom_thickness-0.05])
        alignment_pin();
    }
    // vane to direct air if fan input is offset
    vane_angle=25;
    vane_thickness=1.2;
    min_vane_thickness=0.6;
    *
    translate([fan_output_w/2+fan_shift_x+heater_x_offset,0,fan_box_bottom_thickness])
    rotate([90,0,vane_angle])
    prismoid(size1=[vane_thickness, fan_box_inner_h*0.95], 
        size2=[min_vane_thickness, fan_box_inner_h*0.95],
        h=tunnel_l/cos(vane_angle)-vane_thickness,
        anchor=LEFT+FRONT
    );
    
    module tunnel_housing() {
        //body
        translate([0,0,fan_box_bottom_thickness])
        cuboid(
            [fan_box_inner_w-component_gap*2,tunnel_l-0.01,fan_box_inner_h],
            chamfer=fan_box_inner_h/16,
            edges=[BOTTOM+LEFT, BOTTOM+RIGHT],
            anchor=BOTTOM
        );
        
        // locking indents
        copy_mirror([1,0,0])
        translate([fan_box_inner_w/2-component_gap*2,0,fan_box_inner_h-indent_below_topline])
        locking_indent();
    }
    

    //tunnel_cut();
    module tunnel_cut(){
        // air tunnel, expanding from fan size to heater size
        mirror([1,0,0])
        color("red", 0.4)
        translate([ -heater_x_offset, tunnel_l/2+0.5, heater_tunnel_h/2+tunnel_lift+fan_box_bottom_thickness+fan_box_wall_thickness ])
        rotate([90,0,0])
        prismoid(
            size1=[heater_tunnel_w,heater_tunnel_h], 
            size2=[fan_output_w,fan_output_h],
            //wall=fan_box_wall_thickness, 
            h=tunnel_l+fudge,
            shift=[-fan_output_x_from_center-heater_x_offset, fan_output_y_from_center-tunnel_lift+fan_screw_post_length],
            anchor=BOTTOM // I want to achor by the top for easy alignment, but "shift" moves the top
        );
    }
    

    
}

// a peg for positioning
alignment_pin_d=4;
alignment_pin_l=4;
alignment_pin_chamfer=(alignment_pin_l>alignment_pin_d)?alignment_pin_d/4:alignment_pin_l/4; 
module alignment_pin() {
    cyl(
        l=alignment_pin_l,
        d=alignment_pin_d,
        chamfer2=alignment_pin_chamfer,
        chamfer1=-alignment_pin_chamfer/2,
        anchor=BOTTOM
    );
}


module locking_indent() {
    color("green")
    rotate([90,0,0])
    cyl(l=indent_length, 
        r=indent_depth, 
        rounding=indent_depth/2,
        anchor=CENTER
    );
}

module locking_recess(){
    color("red")
    minkowski() {
        linear_extrude(height=0.01)
        rect([fan_box_inner_w,fan_box_inner_l],
            chamfer=fan_box_inner_l/20, //cut the corner
            anchor=CENTER
        );
        //rounding
        sphere(r=indent_depth);
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
        l=fan_screw_post_length*3,
        d=fan_screw_diam,
        anchor=BOTTOM+CENTER
    );
}
module fan_screw_post() {

    cyl(
        l=fan_screw_post_length,
        d=fan_screw_diam*2,
        anchor=BOTTOM
    );
}

//copy and mirror an object
module copy_mirror(vec=[0,1,0]){
    children();
    if (vec!=undef && vec!=[0,0,0]) {
        mirror(vec) children();
    }
}