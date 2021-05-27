package en;

class Bullet extends Entity {
	public var dmg : Int;
	private function new(x,y) {
		super(x,y);
		frictX = 1;
        frictY = 1;
		dmg = 1;
		//spr.anim.play("mobBullet").loop();
	}

	override function onHitWall() {
		super.onHitWall();
		destroy();
	}

	override public function update() {
		super.update();
		if( !isOnScreen(3) )
		    destroy();
	}
}