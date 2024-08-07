/* Customizable screw cap generator by DrLex.
  Uses screw_extrude function from "customizable round box with threaded lid" by FaberUnserzeit (https://www.thingiverse.com/thing:1648580).
  Released under Creative Commons - Attribution license. */

/* [Screw Thread Parameters] */
// Outer diameter of the male thread on which the cap will be screwed
Thread_OD = 12.0; //[5:.05:80]
// Thread pitch (distance between each turn)
Thread_Pitch = 1.25; //[0.2:.01:5]
// The height of the thread
Thread_Length = 7; //[2:.1:30]
// Space between male thread outer diameter and cap inside diameter
Spacing = 0.4; //[0:.05:2]
// Cut away this much of the thread to make it blunt and easier going
Cut_Thread_Percent = 20; //[0:1:80]
// Extra gap between threads, expressed as fraction of the pitch. Larger gap means thinner thread.
Thread_Gap = 0; //[0:.01:0.5]

/* [Cap Geometry] */
// Thickness of the cap's wall at the closed end
Wall_Thick_1 = 1.2; //[1:.05:6]
// Thickness of the cap's wall at the open end
Wall_Thick_2 = 1.2; //[1:.05:6]
// Thickness of the cap's bottom (or top, depending on how you look at it)
Bottom = 2; //[0.0:.1:10]
// Extra unthreaded part at open end
Extra_Length = 0.5; //[0:.1:5]
// 45 degree bevel, will be clipped to smallest of Extra_Length and Wall_Thick_2
Bevel = 0.5; //[0:.05:2]
// Extra unthreaded part at closed end
Extra_Inside = 0.0; //[0:.1:30]
// For your pleasure
Ribbed = 0; //[0:no, 1:yes]
Number_of_Ribs = 32; //[16:128]
Ribs_Bevel_Top = 0; //[0:no, 1:yes]
Ribs_Bevel_Bottom = 0; //[0:no, 1:yes]

/* [Resolution] */
// Resolution of curves in steps/360°
fn = 96; //[16,32,48,64,96,128,256]

/* [Extras] */
// Use diameter > 0 to make a hole in the cap, will be clipped to wall inner diameter
Hole_dia = 0; //[0:.1:75]

// Number of segments in the hole
Hole_fn = 16; //[3:128]

/* [Visualisation] */
// Enable this to show a cross-section
Sectioned = 0; //[0:no, 1:yes]

/* [Hidden] */
tol = 0.05;
total_height = Bottom + Thread_Length + Extra_Length + Extra_Inside;
outer_dia1 = Thread_OD + 2*(Spacing + Wall_Thick_1);
outer_dia2 = Thread_OD + 2*(Spacing + Wall_Thick_2);

bevel_c = min(Bevel, Extra_Length, Wall_Thick_2);

thread_turns = Thread_Length / Thread_Pitch;
thread_thick = ((Thread_Length/thread_turns)/2);
thread_s = 1 - Thread_Gap;

cut_mittelhoehe = thread_thick*Cut_Thread_Percent/100;
cut_breite = thread_thick*(100-Cut_Thread_Percent)/100;

difference()
{
	Cap();
	if (Sectioned!=0)
	{
        rotate([0, 0, 180]) translate([-outer_dia1, 0, -tol])
			cube([outer_dia1*2, outer_dia1*2, total_height+2*tol]);
	}
}

module Cap()
{
	difference()
	{
        union() {
            translate([0,0,-2*tol])
                cylinder(h=total_height+4*tol, d1 = outer_dia1, d2 = outer_dia2, $fn=Ribbed ? Number_of_Ribs : fn);
            if(Ribbed) {
                rib_offset = [0,0,180/Number_of_Ribs];
                intersection() {
                    Ribs();
                    if(Ribs_Bevel_Top != 0) {
                        rotate(rib_offset) translate([0,0,-tol]) cylinder(h = total_height+2*tol, d1 = outer_dia2+2*total_height, d2 = outer_dia2, $fn=Number_of_Ribs);
                    }
                    if(Ribs_Bevel_Bottom != 0) {
                        rotate(rib_offset) translate([0,0,-tol]) cylinder(h = total_height+2*tol, d1 = outer_dia1, d2 = outer_dia1
                        +2*total_height, $fn=Number_of_Ribs);
                    }
                }
            }
        }
		translate([0,0,Bottom])
			cylinder(r=Thread_OD/2 + Spacing, h=Thread_Length + Extra_Length + Extra_Inside + tol, $fn=fn);
        if(bevel_c > 0) {
            translate([0, 0, total_height - bevel_c - tol]) cylinder(h=bevel_c+2*tol, r1=Thread_OD/2 + Spacing - tol, r2=Thread_OD/2 + Spacing + bevel_c + tol, $fn=fn);
        }
		translate([0,0,-10*tol])
			cylinder(r=outer_dia1, h=10*tol);
        translate([0,0,total_height])
			cylinder(r=outer_dia2, h=10*tol);

        if(Hole_dia > 0) {
            translate([0,0,-tol]) cylinder(r=min(Hole_dia/2, Thread_OD/2 + Spacing), h=2*Bottom, $fn=Hole_fn);
        }
	}

	difference()
	{
		translate([0,0, Extra_Inside + Bottom - Thread_Pitch*.33])
		{	
			screw_extrude
			(
				P = (Cut_Thread_Percent > 0) 
				?
					[
						[tol*2,-(thread_thick*thread_s-tol)],
						[-cut_breite,-cut_mittelhoehe*thread_s],
						[-cut_breite, cut_mittelhoehe*thread_s],
						[tol*2,thread_thick*thread_s-tol]
					]
				:
					[
						[tol,-(thread_thick*thread_s-tol)],
						[-thread_thick,0],
						[tol,thread_thick*thread_s-tol]
					]
				,
				r = Thread_OD / 2 + Spacing,
				p = Thread_Pitch,
				d = 360 * (thread_turns + 0),
				sr = 0,
				er = 45,
				fn = fn
			);
		}
        // Ensure thread does not stick out from top or bottom
		translate([0,0,Extra_Inside + Thread_Length + Bottom - tol])
			cylinder(r=outer_dia1, h=Thread_Pitch+tol);
		translate([0,0,-Thread_Pitch])
			cylinder(r=outer_dia1, h=Thread_Pitch+tol);
	}
}

module Ribs()
{
    angle = 360/Number_of_Ribs;
    x1 = (cos(angle/2) - sin(angle/16)) * outer_dia1/2;
    y1 = sin(angle/2) * outer_dia1/2;
    x2 = (cos(angle/2) - sin(angle/16)) * outer_dia2/2;
    y2 = sin(angle/2) * outer_dia2/2;
    for(n=[0:1:Number_of_Ribs-1]) {
        rotate([0,0,n*angle]) {
            polyhedron([
                [x1, y1, -tol], [x1, -y1, -tol], [x1+y1, 0, -tol],
                [x2, y2, total_height+tol], [x2, -y2, total_height+tol], [x2+y2, 0, total_height+tol]
            ],
            [[0, 1, 2], [0, 3, 4, 1], [0, 2, 5, 3], [1, 4, 5, 2], [3, 5, 4]], convexity=4);
        }
    }
}

/**
 * screw_extrude(P, r, p, d, sr, er, fn)
	by Philipp Klostermann
	
	screw_rotate rotates polygon P 
	with the radius r 
	with increasing height by p mm per turn 
	with a rotation angle of d degrees
	with a starting-ramp of sr degrees length
	with an ending-ramp of er degrees length
	in fn steps per turn.
	
	the points of P must be defined in clockwise direction looking from the outside.
	r must be bigger than the smallest negative X-coordinate in P.
	sr+er <= d
**/

module screw_extrude(P, r, p, d, sr, er, fn)
{
	anz_pt = len(P);
	steps = round(d * fn / 360);
	mm_per_deg = p / 360;
	points_per_side = len(P);
	echo ("steps: ", steps, " mm_per_deg: ", mm_per_deg);
	
	VL = [ [ r, 0, 0] ];
	PL = [ for (i=[0:1:anz_pt-1]) [ 0, 1+i,1+((i+1)%anz_pt)] ];
	V = [
		for(n=[1:1:steps-1])
			let 
			(
				w1 = n * d / steps,
				h1 = mm_per_deg * w1,
				s1 = sin(w1),
				c1 = cos(w1),
				faktor = (w1 < sr)
				?
					(w1 / sr)
				:
					(
						(w1 > (d - er))
						?
							1 - ((w1-(d-er)) / er)
						:
							1
					)
			)
			for (pt=P)
			[
				r * c1 + pt[0] * c1 * faktor, 
				r * s1 + pt[0] * s1 * faktor, 
				h1 + pt[1] * faktor 
			]
	];
	P1 = [
		for(n=[0:1:steps-3])
			for (i=[0:1:anz_pt-1]) 
			[
				1+(n*anz_pt)+i,
				1+(n*anz_pt)+anz_pt+i,
				1+(n*anz_pt)+anz_pt+(i+1)%anz_pt
			] 
			
		
	];
	P2 = 
	[
		for(n=[0:1:steps-3])
			 for (i=[0:1:anz_pt-1]) 
				[
					1+(n*anz_pt)+i,
					1+(n*anz_pt)+anz_pt+(i+1)%anz_pt,
					1+(n*anz_pt)+(i+1)%anz_pt,
				] 
			
		
	];

	VR = [ [ r * cos(d), r * sin(d), mm_per_deg * d ] ];
	PR = 
	[
		for (i=[0:1:anz_pt-1]) 
		[
			1+(steps-1)*anz_pt,
			1+(steps-2)*anz_pt+((i+1)%anz_pt),
			1+(steps-2)*anz_pt+i
		]
	];
			
	VG=concat(VL,V,VR);
	PG=concat(PL,P1,P2,PR);
	convex = round(d/45)+4;
	echo ("convexity = round(d/180)+4 = ", convex);
	polyhedron(VG,PG,convexity = convex);
}

