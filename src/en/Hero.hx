package en;

import format.swf.Data.CXA;

class Hero extends Entity {
    var ca : dn.heaps.Controller.ControllerAccess;
    public function new(x,y) {
        super(x,y);
        
        var g = new h2d.Graphics(spr);
        camera.trackEntity(this, true);
        ignoreColl = false;
        g.beginFill(0xff0000);
        g.drawRect(0,0,16,16);
        ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
    }
    override function dispose() { // call on garbage collection
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function update() { // the Entity main loop

        this.debug(centerX, 0xff0000);
		super.update();
		if(ca.isKeyboardDown(hxd.Key.A))
			dx -= 0.1*tmod;
		if(ca.isKeyboardDown(hxd.Key.D))
			dx += 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.W))
            dy -= 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.S))
            dy += 0.1*tmod;
        if(ca.isKeyboardDown(hxd.Key.SPACE)) {
            var e = new en.HeroBullet(1);
            e.dy = -0.6;
            e.setPosPixel(centerX, centerY);
        }

	}
}