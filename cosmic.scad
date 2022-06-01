echo("\n\n====== COSMIC ENCOUNTER ORGANIZER ======\n\n");

// naming conventions
// A  angle
// V  vector  [W, H] or [W, D, H] or [x, y, z]
// W  width
// D  depth, diameter, thickness
// H  height
// R  radius
// N  number

Qdraft = 15;  // 24 segments per circle (aligns with axes)
Qfinal = 5;  // 72 segments per circle
$fa = Qdraft;
$fs = 0.1;

inch = 25.4;
phi = (1+sqrt(5))/2;

// filament dimensions
Hlayer = 0.2;
extrusion_width = 0.45;
extrusion_overlap = Hlayer * (1 - PI/4);
extrusion_spacing = extrusion_width - extrusion_overlap;

// minimum sizes and rounding
epsilon = 0.01;
function eround(x, e=epsilon) = e * round(x/e);
function eceil(x, e=epsilon) = e * ceil(x/e);
function efloor(x, e=epsilon) = e * floor(x/e);
function tround(x) = eround(x, e=0.05);  // twentieths of a millimeter
function tceil(x) = eceil(x, e=0.05);  // twentieths of a millimeter
function tfloor(x) = efloor(x, e=0.05);  // twentieths of a millimeter

// tidy measurements
function vround(v) = [for (x=v) tround(x)];
function vceil(v) = [for (x=v) tceil(x)];
function vfloor(v) = [for (x=v) tfloor(x)];

// fit checker for assertions
// * vspec: desired volume specification
// * vxmin: exact minimum size from calculations or measurements
// * vsmin: soft minimum = vround(vxmin)
// true if vspec is larger than either minimum, in all dimensions.
// logs its parameters if vtrace is true or the comparison fails.
vtrace = true;
function vfit(vspec, vxmin, title="vfit") = let (vsmin = vround(vxmin))
    (vtrace && vtrace(title, vxmin, vsmin, vspec)) ||
    (vxmin.x <= vspec.x || vsmin.x <= vspec.x) &&
    (vxmin.y <= vspec.y || vsmin.y <= vspec.y) &&
    (vxmin.z <= vspec.z || vsmin.z <= vspec.z) ||
    (!vtrace && vtrace(title, vxmin, vsmin, vspec));
function vtrace(title, vxmin, vsmin, vspec) =  // returns undef
    echo(title) echo(vspec=vspec) echo(vsmin=vsmin) echo(vxmin=vxmin)
    echo(inch=[for (i=vspec) eround(i/inch)]);

function sum(v) = v ? [for(p=v) 1]*v : 0;

// card dimensions
// rectangular area
Vpoker = [2.5*inch, 3.5*inch];  // standard card (poker/collectible)
Vwhist = [2.25*inch, 3.5*inch];  // standard American card (bridge/whist)
Vtarot = [2.75*inch, 4.75*inch];  // standard tarot card
Veuro = [59, 92];  // standard Euro playing card
Valien = [115, 171];  // Cosmic Encounter large alien cards
// thickness (UG deck boxes assume 0.325)
Halien = 0.365;  // 355-370 microns per card
Hcosmic = 0.325;  // ca. 325 microns per card
Hdominion = 0.32;  // ca. 320 microns per card
Hindex = 0.25;  // 200-250 microns per layer

// Gamegenic sleeves
sand_sleeve = [81, 122];  // Dixit
orange_sleeve = [73, 122];  // Tarot
magenta_sleeve = [72, 112];  // Scythe
brown_sleeve = [67, 103];  // 7 Wonders
lime_sleeve = [82, 82];  // Big Square
blue_sleeve = [73, 73];  // Square
dark_blue_sleeve = [53, 53];  // Mini Square
gray_sleeve = [66, 91];  // Standard Card
purple_sleeve = [62, 94];  // Standard European
ruby_sleeve = [46, 71];  // Mini European
green_sleeve = [59, 91];  // Standard American
yellow_sleeve = [44, 67];  // Mini American
catan_sleeve = [56, 82];  // Catan (English)

// Sleeve Kings sleeves
euro_sleeve = [61.5, 94];  // Standard European
super_large_sleeve = [104, 129];

// sleeve thickness
no_sleeve = 0;
md_standard = 0.08;  // 40 micron sleeves (Mayday standard)
ug_classic = 0.08;  // 40 micron sleeves (Ultimate Guard classic)
ug_premium = 0.10;  // 50 micron sleeves (Ultimate Guard premium soft)
sk_standard = 0.13;  // 60 micron sleeves (Sleeve Kings standard)
md_premium = 0.18;  // 90 micron sleeves (Mayday premium)
gg_prime = 0.20;  // 100 micron sleeves (Gamegenic prime)
sk_premium = 0.20;  // 100 micron sleeves (Sleeve Kings premium)
ug_supreme = 0.23;  // 115 micron sleeves (Ultimate Guard supreme)
double_sleeve = 0.30;  // 100 + 50 micron double sleeve

// card metrics
Hcard = Hcosmic + gg_prime;
Vcard = [green_sleeve.x, green_sleeve.y, Hcard];

function card_count(h, d=Hcard) = floor(h / d);
function vdeck(n=1, card=Vcard, wide=false) = [
    wide ? max(card.x, card.y) : min(card.x, card.y),
    wide ? min(card.x, card.y) : max(card.x, card.y),
    n*(card.z)];

Valiens = vdeck(141, [Valien.x, Valien.y, Halien]);
echo(Vcard=Vcard, Valiens=Valiens);

// basic metrics
Dwall = 2;
Hfloor = 2;
Dcut = eround(2/3*Dwall);  // cutting margin for negative spaces
Dgap = 0.1;  // gap between close-fitting parts
echo(Dwall=Dwall, Hfloor=Hfloor, Dgap=Dgap, Dcut=Dcut);

// utilities
function unit_axis(n) = [for (i=[0:1:2]) i==n ? 1 : 0];
module raise(z=Hfloor+epsilon) {
    translate([0, 0, z]) children();
}

// box metrics
Vfloor = [287, 287];  // box floor
Vinterior = [Vfloor.x, Vfloor.y, 69];  // box interior
Hwrap = 55;  // cover art wrap ends here, approximately
module box(size, wall=1, frame=false, a=0) {
    vint = is_list(size) ? size : [size, size, size];
    vext = [vint.x + 2*wall, vint.y + 2*wall, vint.z + wall + Dgap];
    vcut = [vint.x, vint.y, vint.z - wall];
    origin = [0, 0, vext.z/2 - wall];
    translate(origin) rotate(a) {
        difference() {
            cube(vext, center=true);  // exterior
            raise(wall/2) cube(vint, center=true);  // interior
            raise(2*wall) cube(vcut, center=true);  // top cut
            if (frame) {
                for (n=[0:2]) for (i=[-1,+1])
                    translate(2*i*unit_axis(n)*wall) cube(vcut, center=true);
            }
        }
        raise(Hwrap + wall-vext.z/2)
            linear_extrude(1) difference() {
            square([vint.x+wall, vint.y+wall], center=true);
            square([vint.x, vint.y], center=true);
        }
    }
}

// component metrics
Nplayers = 8;
Nsystems = 5;
Dsystem = 72;
Hsystem = 2.3;
Dships = 25.6;
Hships = 24.5;
Dgear = 21.0;  // diamater of ship landing gear

// container metrics
Rint = 1;  // internal corner radius
Rext = Rint + Dwall;  // external corner radius
Hdiv = 1.0;
echo(Rint=Rint, Rext=Rext, Hdiv=Hdiv);

Avee = 60;  // angle for index v-notches and lattices
Dthumb = 25.0;  // index hole diameter
Dstrut = 12.0;  // width of struts and corner braces
echo(Avee=Avee, Dthumb=Dthumb, Dstrut=Dstrut);

Hdeck = Vcard.x + Hfloor + Rext;
function deck_box_volume(d) = [Vcard.y + 2*Rext, d, Hdeck];
Dflare = Valien.x;
Vflare = deck_box_volume(Dflare);

// colors
Cred = "#ff0000";
Corange = "#ff8000";
Cyellow = "#ffff00";
Cgreen = "#00ff00";
Cteal = "#009090";
Ccyan = "#00ffff";
Cblue = "#4040ff";
Cviolet = "#8000ff";
Cblack = "#404040";
Cwhite = "#c0c0c0";
Cgold = "#ffc000";
Csilver = "#a0a0a0";
Ccopper = "#c08000";
player_colors = [
    Cred, Corange, Cyellow, Cgreen, Cblue, Cviolet, Cwhite, Cblack,
];

module prism(h, shape=undef, r=undef, r1=undef, r2=undef,
             scale=1, center=false) {
    module curve() {
        ri = !is_undef(r1) ? r1 : !is_undef(r) ? r : 0;  // inside turns
        ro = !is_undef(r2) ? r2 : !is_undef(r) ? r : 0;  // outside turns
        if (ri || ro) offset(r=ro) offset(r=-ro-ri) offset(r=ri) children();
        else children();
    }
    linear_extrude(height=h, scale=scale, center=center) curve()
    if (is_undef(shape)) children();
    else if (is_list(shape) && is_list(shape[0])) polygon(shape);
    else square(shape, center=true);
}
module lattice_cut(v, i, j=0, h0=0, dstrut=Dstrut/2, a=Avee, r=Rint, tiers=1,
                   flip=false, open=false, center=false, cut=Dcut) {
    // v: lattice volume
    // i: horizontal position
    // j: vertical position
    // h0: z intercept of pattern start (e.g. Hfloor with wall_vee_cut)
    // d: strut width
    // a: strut angle
    // r: corner radius
    // tiers: number of tiers in vertical split
    // center: start pattern at center instead of end
    htri = (v.z - dstrut) / tiers; // trestle height
    dtri = 2*eround(htri/tan(a));  // trestle width (triangle base)
    dycut = v.y + 2*cut; // depth for cutting through Y axis
    dzcut = v.z + 2*cut; // height for cutting through Z axis
    tri = [[dtri/2, -htri/2], [0, htri/2], [-dtri/2, -htri/2]];
    xstrut = eround(dstrut/2/sin(a));
    z0 = (v.z - htri*tiers) / 2;
    x0 = center ? 0 : eround((z0 - h0) / tan(a)) + xstrut + dtri/2;
    y0 = dycut/2;
    nx = center ? i : i + j;
    x = nx/2 * dtri;
    y = (j+1/2) * htri;
    yflip = (1 - (2 * abs((nx+j) % 2))) * (flip ? -1 : +1);
    limit = [v.x-dstrut, v.z];
    xlimit = center ? -limit.x/2 : dstrut/2;
    translate([0, y0, 0]) rotate([90, 0, 0]) linear_extrude(dycut) {
        offset(r=r) offset(r=-dstrut/2-r) intersection() {
            translate([x0, z0] + [x, y])
                scale([1, yflip]) polygon(tri);
            translate([xlimit, 0]) square(limit);
        }
    }
    if (open && j+1 == tiers && yflip < 0) {
        xvee = x0 + x;
        hvee = z0 + y;
        dvee = dtri/2 - 2*xstrut;
        if (xlimit <= xvee - dtri/2 && xvee + dtri/2 <= xlimit+limit.x) {
            translate([xvee, 0, hvee])
                wall_vee_cut([dvee, v.y, v.z-hvee], a=a);
        }
    }
}
module wall_vee_cut(size, a=Avee, cut=Dcut) {
    span = size.x;
    y0 = -2*Rext;
    y1 = size.z;
    rise = y1;
    run = a == 90 ? 0 : rise/tan(a);
    x0 = span/2;
    x1 = x0 + run;
    a1 = (180-a)/2;
    x2 = x1 + Rext/tan(a1);
    x3 = x2 + Rext + epsilon;  // needs +epsilon for 90-degree angles
    poly = [[x3, y0], [x3, y1], [x1, y1], [x0, 0], [x0, y0]];
    rotate([90, 0, 0]) linear_extrude(size.y+2*cut, center=true)
    difference() {
        translate([0, y1/2+cut/2]) square([2*x2, y1+cut], center=true);
        for (s=[-1,+1]) scale([s, 1]) hull() {
            offset(r=Rext) offset(r=-Rext) polygon(poly);
            translate([x0, y0]) square([x3-x0, -y0]);
        }
    }
}

module draw_box(n, adjust=0, feet=true, color=undef) {
    nx = 3;  // wiggle room
    d = round((n+nx) * Hcard + 2 * Dwall) + adjust;
    vbox = deck_box_volume(d);
    echo(draw=n, adjust=adjust, vbox=vbox);
    shell = [vbox.x, vbox.y];
    well = shell - 2*[Dwall, Dwall];
    translate([0, d/2]) color(color) difference() {
        // outer shell
        prism(vbox.z, shell, r=Rext);
        // card well
        raise(Hfloor) prism(vbox.z, well, r=Rint);
        // base round
        raise(-Dgap) prism(vbox.z, shell - 2*[Dstrut, Dstrut], r=Dthumb/2);
        // thumb cut
        vthumb = [inch/sin(Avee), 2*Dwall, inch];
        translate([0, (Dwall-vbox.y)/2, vbox.z-vthumb.z])
            wall_vee_cut(vthumb);
        // front cut
        adraw = 75;
        hvee = vbox.z - Hfloor;  // maximum height
        dtop = vbox.x - 4*Rext;  // maximum width
        dxvee = hvee / tan(adraw);
        vdraw = [dtop - 2*dxvee, 2*Dwall, hvee];
        translate([0, (vbox.y-Dwall)/2, Hfloor]) wall_vee_cut(vdraw, a=adraw);
    }
    // feet
    if (feet) color(color) for (i=[-1,+1]) {
        // center feet in the available space
        xin = inch/sin(Avee) + Rext/tan(Avee);
        xout = vbox.x/2 - Rext;
        xfoot = (xin + xout) / 2;
        translate([i*xfoot, Rext-Dwall, vbox.z-Rext-Rint]) intersection() {
            translate([0, -3/2*Rext]) cube(3*Rext, center=true);
            sphere(Rext);
        }
    }
    translate([0, d + Dgap]) children();
}
module deck_box(d=Dflare, tiers=2, flip=false, color=undef) {
    vbox = deck_box_volume(d);
    shell = [vbox.x, vbox.y];
    well = shell - 2*[Dwall, Dwall];
    // notch dimensions:
    dtop = vbox.x - 2*Dstrut;  // corner supports
    hvee = vbox.z - dtop/2 * sin(Avee);
    vend = [dtop/2, vbox.y, vbox.z-hvee];
    color(color) difference() {
        // outer shell
        prism(vbox.z, shell, r=Rext);
        // card well
        raise(Hfloor) prism(vbox.z, well, r=Rint);
        // base round
        raise(-Dgap) prism(vbox.z, shell - 2*[Dstrut, Dstrut], r=Dthumb/2);
        // side cuts
        raise(hvee) wall_vee_cut(vend);  // end vee
        // lattice
        vlattice = [vbox.y, vbox.x, vbox.z];
        rotate(90) for (j=[0:1:1]) for (i=[-4:1:+4])
            lattice_cut(vlattice, i, j, tiers=tiers,
                flip=flip, center=true);
    }
    %children();
}
module flare_box(d=Dflare, color=undef) {
    deck_box(d, color=color);
    %raise() translate([0, Dwall - Dflare/2])
        flare_decks(Dflare-2*Dwall);
}

function card_pile_size(n) = n*Hcard;
module card_pile(n=10, up=false, wide=true, color=player_colors[7]) {
    hcards = card_pile_size(n);
    vcard = wide ? [Vcard.y, Vcard.x] : [Vcard.x, Vcard.y];
    spin = up ? [90, 0, 0] : 0;
    origin = up ? [0, hcards/2, vcard.y/2] : [0, 0, hcards/2];
    translate(origin) rotate(spin) color(color, 0.5)
        prism(hcards, vcard, center=true);
    translate(spin ? [0, hcards, 0] : [0, 0, hcards]) children();
}
module lean(h, d, amin=0) {
    alean = max(acos(d/h), amin);
    mlean = [
        [1, 0, 0, 0],
        [0, 1, cos(alean), 0],
        [0, 0, sin(alean), 0],
    ];
    multmatrix(m=mlean) children();
}
module flare_decks(d, n=Nplayers, wide=true, lean=true) {
    piles = [34, 44, 60, 37, 12];
    dy = sum(piles) * Hcard + (len(piles) - 1) * Hdiv;
    echo(piles=dy);
    hpile = (wide ? Vcard.x : Vcard.y);
    lean(hpile, d - dy, lean ? 0 : 90) {
        card_pile(piles[0], up=true, wide=wide, color=Csilver)
        card_divider(up=true, color=Cteal)
        card_pile(piles[1], up=true, wide=wide, color=Csilver)
        card_divider(up=true, color=Cgreen)
        card_pile(piles[2], up=true, wide=wide, color=Csilver)
        card_divider(up=true, color=Cyellow)
        card_pile(piles[3], up=true, wide=wide, color=Csilver)
        card_divider(up=true, color=Cred)
        card_pile(piles[4], up=true, wide=wide, color=Csilver);
    }
}

module card_divider(up=false, color=undef) {
    // dividers for the flare box
    v = [Vcard.y + Rint, Vcard.x + Rext];
    a = up ? [90, 0, 0] : 0;
    h = up ? v.y/2 : 0;
    raise(h) rotate(a) color(color) difference() {
        prism(Hdiv, v, r=Rext);
        xthumb = 2/3 * Dthumb;  // depth of thumb round
        vee = [xthumb/sin(Avee), 2*Hdiv, xthumb];
        for (a=[90,-90]) rotate([a, 0, 0]) raise(v.y/2 - vee.z)
            wall_vee_cut(vee);
    }
    raise(up ? 0 : Hdiv) children();
}
module scoop_well(h, v, r0, r1, cut=Dcut) {
    d0 = (sqrt(2)-1)*r0;  // distance from corner to r0 at top
    d1 = (2*sqrt(2)-1)*r1;  // distance from corner to r1 at bottom
    dc = d1 - d0;
    h1 = min(h, dc);  // h1 = dc and h1 = r1 are good alternatives
    hull() {
        raise(h) prism(cut, v, r=r0);
        for (a=[0:$fa:90]) {
            zc = h1*(1+sin(a-90));
            xc = dc*(1-cos(a-90));
            ao = asin(min(0, zc-r1)/r1);
            xo = r1*(1-cos(ao));
            r = (d0+xc-xo) / (sqrt(2)-1) - xo;
            raise(zc) prism(h+epsilon-zc, v-2*[xo, xo], r=r);
        }
    }
}
Vtray = [52, 65];  // covers 1/6 of the ship caddy area
Htray1 = 10;  // room left under ship caddies
Htray2 = 27;  // same as ship caddies
module token_tray(h, scoop=Dstrut/2, color=undef) {
    well = Vtray - 2*[Dwall, Dwall];
    color(color) difference() {
        prism(h, Vtray, r=Rext);
        raise(Hfloor) scoop_well(h-Hfloor, well, r0=Rint, r1=scoop);
    }
    raise(h + Dgap) children();
}

Vships = [ceil(Dships), Nsystems*Dships + 2*Rint, ceil(Hships) + Hfloor];
echo(Vships=Vships);
module ship_caddy(n=Nsystems, d=Vships.x, h=Vships.z, color=undef) {
    w = n*Dships + 2*Rint;
    hpad = 2.0;  // landing pad depth
    apad = tan(48);  // landing pad slope
    dpad = Dgear + 2*hpad/apad;  // landing pad diameter (at top)
    module pads() {
        translate([0, -Dships/2*(n-1), Hfloor])
        for (i=[0:n-1]) translate([0, i*Dships]) children();
    }
    color(color) {
        difference() {
            prism(Hfloor + hpad, [d, w], r=Rext);
            pads() cylinder(d1=Dgear, d2=dpad, h=hpad+epsilon);
        }
        intersection() {
            prism(h, [d, w], r=Rext);
            prism(h, r=Rint) difference() {
                square([d, w+Rext], center=true);
                pads() circle(d=Dships+2*Dgap);
            }
        }
    }
    raise(h+Dgap) children();
}
module system_caddy(color=undef) {
    h0 = Hfloor + Hsystem;  // floor + small tokens
    h = round(h0 + Nsystems*Hsystem);  // system tokens
    d0 = Dsystem - 2*Dgap;
    d1 = Dsystem + 2*Dwall + Dgap;
    color(color) {
        // base
        intersection() {
            raise(h0/2) cube([d0, d0, h0+2*epsilon], center=true);
            difference() {
                prism(h0) circle(d=d1);
                raise(Hfloor) prism(h0) circle(d=5/6*Dsystem);
            }
        }
        // walls
        notch = d1*sin(acos(d0/d1));
        wedge = [[0, 0], [d0, -notch], [d0, notch]];
        prism(h, r=Dwall/3) difference() {
            circle(d=d1);
            circle(d=d1 - 2*Dwall);
            for (a=[0:90:270]) rotate(a) polygon(wedge);
        }
    }
    raise(h+Dgap) children();
}

module organizer(tier=undef) {
    // box shape and manuals
    // everything needs to fit inside this!
    %color("#101080", 0.25) box(Vinterior, frame=true);
    // alien flare storage
    translate([Vinterior.x - Valiens.x, 0] / 2) {
        translate([0, Vinterior.y - Vflare.x] / 2) rotate(-90)
            flare_box(color=Cblack);
        translate([0, Valiens.y - Vinterior.y, Valiens.z] / 2)
            cube(Valiens, center=true);
    }
    // draw decks
    translate([Vflare.x/2-Vinterior.x/2 + Dsystem + Dgap, Vinterior.y/2])
        rotate(180)
        draw_box(24, feet=false, color=Csilver)  // party deck
        draw_box(72, color=Cgold)  // cosmic deck
        draw_box(29, color=Cblack)  // destiny deck
        draw_box(64, color=Cblue)  // rewards deck
        draw_box(28, color=Cred)  // hazard deck
        draw_box(20, adjust=-1, color=Cyellow);  // tech deck
    // home system caddies
    for (i=[0,1]) {
        o = [Dsystem/2 - Vinterior.x/2 + Dgap,
             Vinterior.y/2 - Dsystem/2];
        translate([o.x, o.y - i*Dsystem, 0])
            system_caddy(color=player_colors[i ? 3 : 4])
            system_caddy(color=player_colors[i ? 2 : 5])
            system_caddy(color=player_colors[i ? 1 : 6])
            system_caddy(color=player_colors[i ? 0 : 7]);
    }
    // ship caddies
    for (i=[0:Nplayers-1]) {
        x = i % 6;
        z = i < 6 ? 1 : 0;
        o = [Vships.x/2 - Vinterior.x/2 + x*(Vships.x+Dgap),
             Vships.y/2 - Vinterior.y/2, 10 + Dgap + z*(Vships.z+Dgap)];
        translate(o) ship_caddy(color=player_colors[i]);
    }
    // token trays
    for (i=[0:2]) for (j=[0:1]) {
        o = [Vtray.x/2 - Vinterior.x/2 + i*(Vtray.x+Dgap),
             Vtray.y/2 - Vinterior.y/2 + j*(Vtray.y+Dgap)];
        translate(o) {
            if (i) token_tray(Htray1) token_tray(Htray2);
            else token_tray(Htray1);
        }
    }
}

// scale adjustments:
// to counteract shrinkage, scale X & Y by 100.5% in slicer

print_quality = Qfinal;  // or Qdraft
*flare_box($fa=print_quality);
*draw_box(24, feet=false, $fa=print_quality);  // party deck
*draw_box(72, $fa=print_quality);  // cosmic deck
*draw_box(29, $fa=print_quality);  // destiny deck
*draw_box(64, $fa=print_quality);  // rewards deck
*draw_box(20, adjust=-1, $fa=print_quality);  // tech deck
*draw_box(28, $fa=print_quality);  // hazard deck
*ship_caddy($fa=print_quality);
*system_caddy($fa=print_quality);
*card_divider($fa=print_quality);
*token_tray(Htray1, $fa=print_quality);
*token_tray(Htray2, $fa=print_quality);

organizer();
