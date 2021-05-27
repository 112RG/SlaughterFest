package en;

class Enemy extends Entity {
	public var dmg : Int;
    public static var ALL : Array<Enemy> = [];
	public function new(x,y) {
		super(x,y);
		dmg = 1;
        var g = new h2d.Graphics(spr);
        ALL.push(this);
        ignoreColl = false;
        g.beginFill(0x00FF00);
        g.drawRect(0,0,16,16);
		//spr.anim.play("mobBullet").loop();
	}

	override public function update() {
		super.update();
		if( !isOnScreen(3) )
		    destroy();
	}
}