package en;

import dn.Cooldown;
import hxd.Timer;
import format.swf.Data.CXA;

class Hero extends Entity {
    var ca : dn.heaps.Controller.ControllerAccess;
    public function new(x,y) {
        super(x,y);
        
        var g = new h2d.Graphics(spr);
        camera.trackEntity(this, true);
        ignoreColl = false;
        life = 100;
        maxLife = 100;
        spr.set("fxSmallCircle", 0);
        ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
    }
    override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}
    override public function hit(dmg:Int) {
		fx.flashBangS(0xFF0000,0.2);
		super.hit(dmg);
	}
	override function update() { // the Entity main loops
        hud.debug(cd.has('fire'), true);

		super.update();
		if(ca.isKeyboardDown(hxd.Key.A))
			dx -= 0.1*tmod;
		if(ca.isKeyboardDown(hxd.Key.D))
			dx += 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.W))
            dy -= 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.S))
            dy += 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.SPACE) && !cd.has('fire')) {
            var e = new en.HeroBullet(1);
            e.dy = -0.6;
            e.setPosPixel(centerX, centerY);
            cd.setS('fire', 0.3);
        }

	}
}