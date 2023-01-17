/*

Name:        Headboard for 16mm scale model railway trains
Model URI:   https://snwd.uk/3dp_headboard
Description: Headboard with customisable lettering for 16mm scale model railways
Version:     v1.0
Creator:     Simon Wood
Creator URI: https://simonwood.info
License:     CC-NC-BY-SA 4.0
License URI: https://creativecommons.org/licenses/by-nc-sa/4.0/

This model uses Fontmetrics 
https://github.com/arpruss/miscellaneous-scad/blob/master/fontmetrics.scad
Copyright (c) 2016 Alexander R. Pruss
License: (MIT) https://github.com/arpruss/miscellaneous-scad/blob/master/LICENSE

*/
 
 // Upper row text
Upper_row_text="SANTA";
//  Lower row text
Lower_row_text="SPECIAL";
//  How thick the board on which the lettering is placed should be
backboard_depth=2;
//  How high the letters should be
font_size=6;
//  The thickness of the letters above the board
lettering_depth=1;
//  The radius of arc forming the outer edge of the headboard
outer_radius=50;
//  How big the border around the edge of the board should be
border_width=1;

use <fontmetrics.scad>;

headboard(backboard_depth,outer_radius,font_size,lettering_depth,border_width,[Upper_row_text,Lower_row_text]);
module headboard(backboard_depth,outer_radius,font_size,lettering_depth,border_width,texts) {
    headboard_angle = headboard_angle();
    difference() {
        union() {
            backboard();
            translate([0,0,backboard_depth]) {
                border();
                lettering(0);
                lettering(1);
            }
        }
        cutouts();
    }
    module backboard() {
        arc(backboard_depth,outer_radius,backboard_height(),headboard_angle);
    }
    module border() {
        arc(lettering_depth,outer_radius,border_width,headboard_angle);
        arc(lettering_depth,outer_radius-backboard_height()+border_width,border_width,headboard_angle);
        for(i=[0:1]) 
            mirror( [i, 0, 0] ) {
                rotate(headboard_angle/2)
                    translate([0,outer_radius,0])
                        rotate(cutout_angle()/2-180)
                            arc(lettering_depth,cutout_radius(),border_width,cutout_angle());
                rotate(headboard_angle/2)
                    translate([0,outer_radius-backboard_height(),0])
                        cube([border_width,backboard_height(),lettering_depth]);
        }
    }
    module lettering(row=0) {
        linear_extrude(lettering_depth)
            text_arc(texts[row],outer_radius-(1.25+row*1.5)*font_size-border_width,font_size,true);
    }
    module cutouts() {
        for(i=[0:1])
            mirror( [i, 0, 0] )
                rotate(headboard_angle/2)
                    translate([0,outer_radius,-1])
                        cylinder(backboard_depth+lettering_depth+2,backboard_height()/2,backboard_height()/2);     
    }
    function backboard_height() = 3*font_size+2*border_width;
    function headboard_angle() = max(
        add_elements(angles_of_letters(texts[0],outer_radius-(1.25+0*1.5)*font_size-border_width,font_size))+2*angle_subtended_by_arc(outer_radius,cutout_radius()),
        add_elements(angles_of_letters(texts[1],outer_radius-(1.25+1*1.5)*font_size-border_width,font_size))+2*angle_subtended_by_arc(outer_radius-backboard_height(),border_width)
    );
    function cutout_radius() = backboard_height()/2+border_width;
    function cutout_angle() = acos(cutout_radius()/(2*outer_radius));
}
function angle_subtended_by_arc(radius,arc_length) = arc_length*360/(2*radius*PI);
function longer_string(s1,s2) = len(s1)>len(s2) ? s1 : s2;
function add_elements(array, to=-1, from=0) = from < len(array) - 1 && (from < to || to == -1) ? array[from] + add_elements(array, to, from + 1) : array[from];
function angles_of_letters(the_text,radius,font_size) = [for (i=[0:len(the_text)-1]) angle_subtended_by_arc(radius,measureText(the_text[i],size=font_size))];
module text_arc(the_text,radius,font_size,center=false) {
    angles_of_letters=angles_of_letters(the_text,radius,font_size);
    center_offset = center ? add_elements(angles_of_letters,len(the_text)-1)/2 : 0;
        for (i = [0:len(the_text)-1]) {
            rotate(i == 0 ? center_offset : center_offset-add_elements(angles_of_letters,i-1))
                translate([0,radius,0])
                    text(the_text[i],halign="left",font_size); 
    }

}
module tube(height,radius,thickness) {
    difference(){
        cylinder(height,radius,radius);
        translate([0,0,-1])
            cylinder(height+2,radius-thickness,radius-thickness);
    }
}
module arc(height,radius,thickness,angle) {
    difference(){
        tube(height,radius,thickness);
        translate([0,0,-1])
            for(i=[0:1]) 
                mirror( [i, 0, 0] )
                    rotate(90+angle/2)
                        translate([-radius,0,0])
                            cube([2*radius,radius,height+2]);
    }
}
$fn=100;