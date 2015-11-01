// Schlage SC4 Key Template - by Kevin Li <https://github.com/KevinLi>
// This work is a derivative of sc1.scad from "Physical Keygen" by Nirav Patel
// This work is licensed under a Creative Commons Attribution 3.0 Unported License.


// Physical Keygen - by Nirav Patel <http://eclecti.cc>
//
// Generate a duplicate of a Schlage SC4 key by editing the last line of the file
// and entering in the key code of the lock.  If you don't know the key code,
// you can measure the key and compare the numbers at:
// http://web.archive.org/web/20050217020917fw_/http://dlaco.com/spacing/tips.htm
//
// This work is licensed under a Creative Commons Attribution 3.0 Unported License.

// Since the keys and locks I have were all designed in imperial units, the
// constants in this file will be defined in inches.  The mm function
// allows us to retain the proper size for exporting a metric STL.
function mm(i) = i*25.4;

module rounded(size, r) {
	union() {
		translate([r, 0, 0]) cube([size[0]-2*r, size[1], size[2]]);
		translate([0, r, 0]) cube([size[0], size[1]-2*r, size[2]]);
		translate([r, r, 0]) cylinder(h=size[2], r=r);
		translate([size[0]-r, r, 0]) cylinder(h=size[2], r=r);
		translate([r, size[1]-r, 0]) cylinder(h=size[2], r=r);
		translate([size[0]-r, size[1]-r, 0]) cylinder(h=size[2], r=r);
	}
}

module bit() {
	w = mm(1/4);
	difference() {
		translate([-w/2, 0, 0]) cube([w, w, w]);
		translate([-mm(8/256), 0, 0]) rotate([0, 0, 140]) cube([w, w, w]);
		translate([ mm(8/256), 0, 0]) rotate([0, 0, -50]) cube([w, w, w]);
	}
}

// Schlage SC4 6 pin key.
// The measurements are from publicly available information.
module sc4(bits) {
	thickness = mm(5/64);
	length = mm(19/16);
	width = mm(0.343);

	shoulder = mm(0.231);
	pin_spacing = mm(0.1562);
	depth_inc = mm(0.015);

	// Less fudge, more difference between key width and depth 0
	fudge = mm(0.008);

	// Handle size
	h_l = mm(1);
	h_w = mm(1);
	h_d = mm(1/16);
	difference() {
		// blade and key handle
		union() {
			translate([-h_l, -h_w/2 + width/2, 0]) rounded([h_l, h_w, thickness], mm(1/4));
			intersection() {
				// cut a little off the tip to avoid going too long
				cube([length - mm(1/64), width, thickness]);
				translate([0, mm(1/4), thickness*3/4]) rotate([0, 90, 0]) cylinder(h=length, r=mm(1/4), $fn=64);
			}
		}

		// chamfer the tip
		translate([length, mm(1/8), 0]) {
			rotate([0, 0, 45]) cube([10, 10, thickness]);
			rotate([0, 0, 225]) cube([10, 10, thickness]);
		}

		// Bottom cut
		cube([mm(1/16), mm(1/64), thickness]);

		// put in a hole for keychain use
		translate([-h_l + mm(3/16), width/2, 0]) cylinder(h=thickness, r=mm(1/8));

		// cut the channels in the key.  designed more for printability than accuracy
		union() {
			translate([-h_d, mm(9/64), thickness/2]) rotate([62, 0, 0]) cube([length + h_d, width, width]);
			translate([-h_d, mm(7/64), thickness/2]) rotate([55, 0, 0]) cube([length + h_d, width, width]);
			translate([-h_d, mm(7/64), thickness/2]) cube([length + h_d, mm(1/32), width]);
		}

		translate([-h_d, width - mm(9/64), 0]) cube([length + h_d, width - (width - mm(10/64)), thickness/2]);
		translate([-h_d, width - mm(9/64), thickness/2]) rotate([-110, 0, 0]) cube([length + h_d, width, thickness/2]);

		intersection() {
			translate([-h_d, mm(1/32), thickness/2]) rotate([-118, 0, 0]) cube([length + h_d, width, width]);
			translate([-h_d, mm(1/32), thickness/2]) rotate([-110, 0, 0]) cube([length + h_d, width, width]);
		}

		// Do the actual bitting
		for (b = [0:5]) {
			translate([shoulder + b*pin_spacing, width - bits[b]*depth_inc - fudge, 0]) bit();
		}
	}
}

sc4([4,4,6,9,5,2]);
