package en;

import hxd.Key;

class HeroBullet extends en.Bullet {
	public function new(dmgBonus:Int) {
		super(0,0);
		this.dmg = 1+dmgBonus;
		spr.anim.playAndLoop(bullets.fxBullet);
		spr.anim.setSpeed(0.4);
		//spr.anim.playAndLoop();
		//spr.anim.playAndLoop('fxBullet');
		//spr.set(dict.fxCircle15, 0);
		//spr.setCenterRatio(0.5,0.5);
		ignoreColl = false;
	}

	override function physicsUpdate() {
		super.physicsUpdate();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.rotation = Math.atan2(dy,dx);
	}

	function onHit(e:Entity) {
		fx.hit(centerX, centerY);
		e.hit(dmg);
		destroy();
	}

	override function onStep() {
		super.onStep();
		for(e in Enemy.ALL)
			if( !e.destroyed && dist(e)<=e.radius ) {
				onHit(e);
				break;
			}
	}

	override public function update() {
		super.update();
	}
}