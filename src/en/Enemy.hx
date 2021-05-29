package en;

class Enemy extends Entity {
	public var dmg : Int;
    public static var ALL : Array<Enemy> = [];
	var path : Array<CPoint> = [];
	#if debug
	private var trackPath = new h2d.Graphics(game.scroller);
	#end
	public function new(x,y) {
		super(x,y);
		dmg = 1;
        ALL.push(this);
        ignoreColl = false;
		spr.set(dict.fxCircle7);
		weight = 5;
		//spr.anim.play("mobBullet").loop();
	}

	override public function update() {
		super.update();
		goto(game.hero.cx, game.hero.cy);
		#if debug
		trackPath.clear();

		for (key => value in path){
			trackPath.beginFill(0x0,1);
			if(path.length > 0)
				if(key == 0) {
					trackPath.lineStyle(1,0xFF329F,1);
					trackPath.moveTo(this.centerX, this.centerY);
					trackPath.lineTo(value.centerX, path[key].centerY);
				} else {
					trackPath.lineStyle(1,Std.int(rnd(1,90000)),1);
					trackPath.moveTo(path[key-1].centerX, path[key-1].centerY);
					trackPath.lineTo(value.centerX, value.centerY);
				}

			else 
				trackPath.lineTo(value.centerX, value.centerY);

			trackPath.endFill();
		} 
		#end
		if( path.length>0 ) {
			var next = path[0];
			while( next!=null && next.distCase(this)<=0.2 ) {
				path.shift();
				next = path[0];
			}
			if( next!=null ) {
				
				// Movement
				if( ui.Console.ME.hasFlag("path") )
					fx.markerCase(next.cx, next.cy, 0.1);
				var s = 0.008;
				var a = Math.atan2(next.footY-footY, next.footX-footX);
				dx+=Math.cos(a)*s*tmod;
				dy+=Math.sin(a)*s*tmod;

				// Try to stick to cell center
				var a = Math.atan2(0.5-yr, 0.5-xr);
				dx+=Math.cos(a)*0.001*tmod;
				dy+=Math.sin(a)*0.001*tmod;

				dir = next.cx<cx ? -1 : next.cx>cx ? 1 : dir;

			}
		}
		//if( !isOnScreen(3) )
		 //   destroy();
	}
	override function onDie() {
		super.onDie();
		game.addScore(this,1);
		//fx.dotsExplosionExample(centerX, centerY, 0x808080);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		trackPath.clear();
	}
	override function onStep() {
		super.onStep();
		if( !game.hero.destroyed && dist(game.hero)<=game.hero.radius )
			onHit(game.hero);
	}

	function goto(x,y) {
		//this.setPosPixel(this.centerX, this.centerY);
		//var a = Math.atan2(game.hero.centerY-this.centerY, game.hero.centerX-this.centerX);
		//var s = 0.1;
		//this.dx = Math.cos(a)*s;
		//this.dy = Math.sin(a)*s;
		//#if debug

		if( !sightCheckCase(x,y) ) {
			path = level.pf.getPath(cx,cy, x,y);
			// path = level.pf.smooth( level.pf.getPath({x:cx, y:cy}, {x:x, y:y}) ).map( function(pt) return new CPoint(pt.x, pt.y) );
			// path.shift();
		}
		else
			path = [ new CPoint(x,y) ];
		
/* 		
		#end */
	}
	function onHit(e:Entity) {
		e.hit(dmg);
		destroy();
	}
	override function physicsUpdate() {
		super.physicsUpdate();
	}
}