package en;

import h3d.Vector;
import dn.pathfinder.AStar;

class Enemy extends Entity {
	public var dmg : Int;
    public static var ALL : Array<Enemy> = [];
	private var path = new h2d.Graphics(game.scroller);
	public function new(x,y) {
		super(x,y);
		dmg = 1;
        ALL.push(this);
        ignoreColl = false;
		spr.set("fxCircle", 0);
		spr.setCenterRatio(0.5,0.5);
		weight = 5;
		
		//spr.anim.play("mobBullet").loop();

	}

	override public function update() {
		super.update();
		trackHero();
		
		//if( !isOnScreen(3) )
		 //   destroy();
	}
	override function onDie() {
		super.onDie();
		game.addScore(this,1);
		fx.dotsExplosionExample(centerX, centerY, 0x808080);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		path.clear();
	}
	override function onStep() {
		super.onStep();
		if( !game.hero.destroyed && dist(game.hero)<=game.hero.radius )
			onHit(game.hero);
	}

	function trackHero() {
		//this.setPosPixel(this.centerX, this.centerY);
		var a = Math.atan2(game.hero.centerY-this.centerY, game.hero.centerX-this.centerX);
		var s = 0.1;

		this.dx = Math.cos(a)*s;
		this.dy = Math.sin(a)*s;
		#if debug
		path.clear();
		path.beginFill(0x0,1);
		path.lineStyle(1,0xffffff,1);
		path.moveTo(game.hero.centerX, game.hero.centerY);
		path.lineTo(this.centerX, this.centerY);
		path.endFill();
		#end
	}
	function onHit(e:Entity) {
		e.hit(dmg);
		destroy();
	}
	override function physicsUpdate() {
		super.physicsUpdate();
	}
}