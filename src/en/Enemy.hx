package en;

class Enemy extends Entity {
	public var dmg : Int;
    public static var ALL : Array<Enemy> = [];
	public function new(x,y) {
		super(x,y);
		dmg = 1;
        ALL.push(this);
        ignoreColl = false;
		spr.set("fxCircle", 0);
		spr.setCenterRatio(0.9,0.5);
		weight = 5;
		//spr.anim.play("mobBullet").loop();

	}

	override public function update() {
		super.update();
		trackHero();
		//if( !isOnScreen(3) )
		 //   destroy();
	}

	override function onStep() {
		super.onStep();
		if( !game.hero.destroyed && dist(game.hero)<=game.hero.radius )
			onHit(game.hero);
	}

	function trackHero() {
		//this.setPosPixel(this.centerX, this.centerY);
		var a = Math.atan2(game.hero.centerY-this.rnd(10,16)-this.centerY, game.hero.centerX-this.centerX);
		var s = 0.3;
		this.dx = Math.cos(a)*s;
		this.dy = Math.sin(a)*s;
	}
	function onHit(e:Entity) {
		e.hit(dmg);
		destroy();
	}
	override function physicsUpdate() {
		super.physicsUpdate();
	}
}