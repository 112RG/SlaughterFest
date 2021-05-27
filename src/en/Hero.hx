package en;

import dn.Bresenham;
import dn.Cooldown;
import hxd.Timer;
import format.swf.Data.CXA;

class Hero extends Entity {
    var ca : dn.heaps.Controller.ControllerAccess;
    var anims = dn.heaps.assets.Aseprite.getDict( hxd.Res.atlas.hero );
    private var path = new h2d.Graphics(game.scroller);
    public function new(x,y) {
        super(x,y);
        
        var g = new h2d.Graphics(spr);
        camera.trackEntity(this, true);
        ignoreColl = false;
        life = 100;
        maxLife = 100;
        //spr.set("hero", 0);
        spr.filter = new dn.heaps.filter.PixelOutline(0x330000, 0.4);
		spr.set(Assets.hero);
        spr.anim.registerStateAnim(anims.idle, 0);
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

		super.update();
        var a = Math.atan2(Main.ME.mouseY-this.centerY, Main.ME.mouseX-this.centerX);
    
        var tx = Math.cos(a);
        var ty = Math.sin(a);
        #if debug
        path.clear();
        path.beginFill(0x0,1);
        path.lineStyle(1,0xFFFF00,1);
        path.moveTo(this.centerX, this.centerY);
        path.lineTo(Main.ME.mouseX, Main.ME.mouseY);
        path.endFill();
        #end
		if(ca.isKeyboardDown(hxd.Key.A))
			dx -= 0.05*tmod;
		if(ca.isKeyboardDown(hxd.Key.D))
			dx += 0.05*tmod;
        if(ca.isKeyboardDown(hxd.Key.W))
            dy -= 0.05*tmod;
        if(ca.isKeyboardDown(hxd.Key.S))
            dy += 0.05*tmod;
        if(ca.isKeyboardDown(hxd.Key.SPACE) && !cd.has('fire')) {
            var e = new en.HeroBullet(1);
            e.dx = tx;
            e.dy = ty;


            e.setPosPixel(centerX, centerY);
            cd.setS('fire', 0.2);
        }

	}
}