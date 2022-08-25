echo("\n\n====== COSMIC ENCOUNTER ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

// card metrics
Hcard = Hcard_cosmic + Hsleeve_prime;
Vcard = Vsleeve_green;  // 59x91
Vcard_divider = [62, 92];  // 62x92
Valiens = deck_volume(141, size=Vcard_alien, height=Hcard_alien);
echo(Vcard_divider=Vcard_divider, Valiens=Valiens);
Htray = 27;  // same as ship caddies
Vtray = [52, 65, Htray];  // covers 1/6 of the ship caddy area
Htray_short = 10;  // room left under ship caddies
Hlip = Rext;

// box metrics
Vgame = [288, 288, 69];  // box interior
Hwrap = 55;  // cover art wrap ends here, approximately

// component metrics
Nplayers = 8;
Nsystems = 5;
Dsystem = 72;
Hsystem = 2.3;
Dships = 25.6;
Hships = 24.5;
Dgear = 21.0;  // diamater of ship landing gear
Vships = [ceil(Dships), Nsystems*Dships + 2*Rint, ceil(Hships) + Hfloor];
echo(Vships=Vships);

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

// TODO: merge this with deck_box
module draw_box(n, adjust=0, feet=true, color=undef) {
    nx = 3;  // wiggle room
    d = round((n+nx) * Hcard + 2 * Dwall) + adjust;
    vbox0 = deck_box_volume(width=d);
    vbox = [vbox0.y, vbox0.x, vbox0.z];
    echo(draw=n, adjust=adjust, vbox=vbox);
    shell = [vbox.x, vbox.y];
    well = shell - 2*[Dwall, Dwall];
    translate([0, d/2]) colorize(color) difference() {
        // outer shell
        prism(shell, height=vbox.z, r=Rext);
        // card well
        raise(Hfloor) prism(well, height=vbox.z, r=Rint);
        // thumb cut
        vthumb = [Dthumb/sin(Avee), 2*Dwall, Dthumb];
        translate([0, (Dwall-vbox.y)/2, vbox.z-vthumb.z])
            wall_vee_cut(vthumb);
        // front cut
        adraw = 75;
        hvee = vbox.z - Hfloor;  // maximum height
        dtop = vbox.x - 4*Rext;  // maximum width
        dxvee = hvee / tan(adraw);
        vdraw = [dtop - 2*dxvee, 2*Dwall, hvee];
        translate([0, (vbox.y-Dwall)/2, Hfloor])
            wall_vee_cut(vdraw, angle=adraw);
    }
    // feet
    if (feet) colorize(color) for (i=[-1,+1]) {
        // center feet in the available space
        xin = Dthumb/sin(Avee) + Rext/tan(Avee);
        xout = vbox.x/2 - Rext;
        xfoot = (xin + xout) / 2;
        translate([i*xfoot, Rext-Dwall, vbox.z-Rext-Rint]) intersection() {
            translate([0, -3/2*Rext]) cube(3*Rext, center=true);
            sphere(Rext);
        }
    }
    translate([0, d + Dgap]) children();
}
module flare_box(d=Vcard_alien.x, color=undef) {
    deck_box(width=d, color=color);
    %raise() translate([Dwall - d/2, 0])
        flare_decks(d-2*Dwall);
}
module flare_decks(d, n=Nplayers, wide=true, lean=true) {
    piles = [34, 44, 60, 37, 12];
    dy = sum(piles) * Hcard + (len(piles) - 1) * Hcard_divider;
    vflare = [dy, Vcard_divider.y, Vcard.x];
    lean(vflare, space=d, angle=(lean ? undef : 90)) {
        deck(piles[0], up=true, color=Csilver)
        deck_divider(up=true, color=Cteal)
        deck(piles[1], up=true, color=Csilver)
        deck_divider(up=true, color=Cgreen)
        deck(piles[2], up=true, color=Csilver)
        deck_divider(up=true, color=Cyellow)
        deck(piles[3], up=true, color=Csilver)
        deck_divider(up=true, color=Cred)
        deck(piles[4], up=true, color=Csilver);
    }
}
module cosmic_token_tray(size=Vtray, height=undef, color=undef) {
    v = volume(size, height);
    lip = max(0, v.z - Htray_short);
    scoop_tray(size=v, lip=lip, color=color);
}
module ship_caddy(n=Nsystems, d=Vships.x, h=Vships.z, color=undef) {
    w = n*Dships + 2*Rint;
    hpad = 2.0;  // landing pad depth
    apad = tan(48);  // landing pad slope
    dpad = Dgear + 2*hpad/apad;  // landing pad diameter (at top)
    module pads() {
        translate([0, -Dships/2*(n-1), Hfloor])
        for (i=[0:n-1]) translate([0, i*Dships]) children();
    }
    colorize(color) {
        difference() {
            prism([d, w], height=Hfloor+hpad, r=Rext);
            pads() cylinder(d1=Dgear, d2=dpad, h=hpad+EPSILON);
        }
        intersection() {
            prism([d, w], height=h, r=Rext);
            prism(height=h, r=Rint) difference() {
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
    colorize(color) {
        // base
        intersection() {
            raise(h0/2) cube([d0, d0, h0+2*EPSILON], center=true);
            difference() {
                prism(height=h0) circle(d=d1);
                raise(Hfloor) prism(height=h0) circle(d=5/6*Dsystem);
            }
        }
        // walls
        notch = d1*sin(acos(d0/d1));
        wedge = [[0, 0], [d0, -notch], [d0, notch]];
        prism(height=h, r=Dwall/3) difference() {
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
    %colorize("#101080", 0.25) box_frame();
    dbox = deck_box_volume().y;  // deck box width
    // alien flare storage
    translate([Vgame.x - Valiens.x, 0] / 2) {
        translate([0, Vgame.y - dbox] / 2)
            flare_box(color=Cblack);
        %translate([0, Valiens.y - Vgame.y, Valiens.z] / 2)
            cube(Valiens, center=true);
    }
    // draw decks
    translate([dbox/2-Vgame.x/2 + Dsystem + Dgap, Vgame.y/2])
        rotate(180)
        draw_box(24, feet=false, color=Csilver)  // party deck
        draw_box(72, color=Cgold)  // cosmic deck
        draw_box(29, color=Cblack)  // destiny deck
        draw_box(64, color=Cblue)  // rewards deck
        draw_box(28, color=Cred)  // hazard deck
        draw_box(20, adjust=-1, color=Cyellow);  // tech deck
    // home system caddies
    for (i=[0,1]) {
        o = [Dsystem/2 - Vgame.x/2 + Dgap,
             Vgame.y/2 - Dsystem/2];
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
        o = [Vships.x/2 - Vgame.x/2 + x*(Vships.x+Dgap),
             Vships.y/2 - Vgame.y/2, 10 + Dgap + z*(Vships.z+Dgap)];
        translate(o) ship_caddy(color=player_colors[i]);
    }
    // token trays
    for (i=[0:2]) for (j=[0:1]) {
        o = [Vtray.x/2 - Vgame.x/2 + i*(Vtray.x+Dgap),
             Vtray.y/2 - Vgame.y/2 + j*(Vtray.y+Dgap)];
        translate(o) {
            cosmic_token_tray(height=Htray_short);
            if (i) raise(Htray_short+Dgap) cosmic_token_tray(height=Htray);
        }
    }
}

// scale adjustments:
// to counteract shrinkage, scale X & Y by 100.5% in slicer

*flare_box($fa=Qprint);
*draw_box(24, feet=false, $fa=Qprint);  // party deck
*draw_box(72, $fa=Qprint);  // cosmic deck
*draw_box(29, $fa=Qprint);  // destiny deck
*draw_box(64, $fa=Qprint);  // rewards deck
*draw_box(20, adjust=-1, $fa=Qprint);  // tech deck
*draw_box(28, $fa=Qprint);  // hazard deck
*ship_caddy($fa=Qprint);
*system_caddy($fa=Qprint);
*deck_divider($fa=Qprint);
*cosmic_token_tray(height=Htray_short, $fa=Qprint);
*cosmic_token_tray(height=Htray, $fa=Qprint);

organizer();
