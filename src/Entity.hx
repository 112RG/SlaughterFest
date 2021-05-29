import dn.Bresenham;
import en.Hero;

class Entity {
    public static var ALL : Array<Entity> = [];
    public static var GC : Array<Entity> = [];

	// Various getters to access all important stuff easily
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;
	public var ftime(get,never) : Float; inline function get_ftime() return game.ftime;
	public var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;
	public var hud(get,never) : ui.Hud; inline function get_hud() return Game.ME.hud;
	public var camera(get,never) : Camera; inline function get_camera() return game.camera;
	public var hero(get,never) : Hero; inline function get_hero() return Game.ME.hero;

	/** Cooldowns **/
	public var cd : dn.Cooldown;
	var dict = Assets.tilesDict;
	var bullets = Assets.bulletDict;

	/** Unique identifier **/
	public var uid(default,null) : Int;

	// Position in the game world
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.5;
    public var yr = 1.0;

	// Velocities
    public var dx = 0.;
	public var dy = 0.;
	// Uncontrollable bump velocities, usually applied by external
	// factors (think of a bumper in Sonic for example)
    public var bdx = 0.;
	public var bdy = 0.;


	public inline function angTo(e:Entity) return Math.atan2(e.footY-footY, e.footX-footX);

	// Velocities + bump velocities
	public var dxTotal(get,never) : Float; inline function get_dxTotal() return dx+bdx;
	public var dyTotal(get,never) : Float; inline function get_dyTotal() return dy+bdy;

	// Multipliers applied on each frame to normal velocities
	public var frictX = 0.82;
	public var frictY = 0.82;

	// Multiplier applied on each frame to bump velocities
	public var bumpFrict = 0.93;
	public var hei : Float = Const.GRID;
	public var radius = Const.GRID*0.5;

	/** Horizontal direction, can only be -1 or 1 **/
	public var dir(default,set) = 1;


	public var life : Int;
	public var maxLife : Int;

	public var weight: Int;
	// Sprite transformations
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;
	public var entityVisible = true;
	public var ignoreColl : Bool;
    public var spr : HSprite;
	public var colorAdd : h3d.Vector;
	var debugLabel : Null<h2d.Text>;

	// Coordinates getters, for easier gameplay coding
	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var headX(get,never) : Float; inline function get_headX() return footX;
	public var headY(get,never) : Float; inline function get_headY() return footY-hei;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-hei*0.5;

	var actions : Array<{ id:String, cb:Void->Void, t:Float }> = [];

    public function new(x:Int, y:Int) {
        uid = Const.NEXT_UNIQ;
		ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
        setPosCase(x,y);
		ignoreColl = true;
        spr = new HSprite(Assets.tiles);
        Game.ME.scroller.add(spr, Const.DP_MAIN);
		spr.setCenterRatio(0.5,1);
    }

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public inline function isAlive() {
		return !destroyed;
	}

	public function kill(by:Null<Entity>) {
		destroy();
	}
	public function hit(dmg:Int) {
		//blink();
		life-=dmg;
		if( life<=0 && !destroyed ) {
			life = 0;
			onDie();
		}
	}
	function onDie() {
		destroy();
	}
	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	public inline function bumpAwayFrom(e:Entity, spd:Float, ?spdZ=0., ?ignoreReduction=false) {
		var a = e.angTo(this);
		bump(Math.cos(a)*spd, Math.sin(a)*spd*0.5, spdZ, ignoreReduction);
	}
	public function bump(x:Float,y:Float,z:Float, ?ignoreReduction=false) {
		var f = ignoreReduction ? 1.0 : 1-0.4;
		bdx+=x*f;
		bdy+=y*f;
		dy+=z*f;
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}


	public function isOnScreen(cPadding=1) {
		return
			cx>=-cPadding
			&& cx<level.pxWid+cPadding
			&& centerY>=game.camera.top-cPadding*Const.GRID
			&& centerY<game.camera.bottom+cPadding*Const.GRID;
	}

	public function is<T:Entity>(c:Class<T>) return Std.isOfType(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.downcast(this, c);

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return M.pretty(v,p);

	public inline function dirTo(e:Entity) return e.centerX<centerX ? -1 : 1;
	public inline function dirToAng() return dir==1 ? 0. : M.PI;
	public inline function getMoveAng() return Math.atan2(dyTotal,dxTotal);

	public inline function distCase(e:Entity) return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	public inline function distCaseFree(tcx:Int, tcy:Int, ?txr=0.5, ?tyr=0.5) return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);

	public inline function distPx(e:Entity) return M.dist(footX, footY, e.footX, e.footY);
	public inline function distPxFree(x:Float, y:Float) return M.dist(footX, footY, x, y);
	public inline function dist(?e:Entity, ?x:Float, ?y:Float) {
		return M.dist(centerX, centerY, e!=null ? e.centerX : x, e!=null ? e.centerY : y);
	}

	public inline function sightCheckCase(tcx:Int, tcy:Int) {
		return Bresenham.checkThinLine(cx,cy,tcx,tcy, function(x,y) return !level.hasAnyCollision(x,y));
	}
	
	public function makePoint() return LPoint.fromCase(cx+xr,cy+yr);

    public inline function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

		colorAdd = null;

		spr.remove();
		spr = null;

		if( debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}

		cd.destroy();
		cd = null;
    }

	public inline function debugFloat(v:Float, ?c=0xffffff) {
		debug( pretty(v), c );
	}
	public inline function debug(?v:Dynamic, ?c=0xffffff) {
		#if debug
		if( v==null && debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}
		if( v!=null ) {
			if( debugLabel==null )
				debugLabel = new h2d.Text(Assets.fontTiny, Game.ME.scroller);
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	function chargeAction(id:String, sec:Float, cb:Void->Void) {
		if( isChargingAction(id) )
			cancelAction(id);
		if( sec<=0 )
			cb();
		else
			actions.push({ id:id, cb:cb, t:sec});
	}

	public function isChargingAction(?id:String) {
		if( id==null )
			return actions.length>0;

		for(a in actions)
			if( a.id==id )
				return true;

		return false;
	}

	public function cancelAction(?id:String) {
		if( id==null )
			actions = [];
		else {
			var i = 0;
			while( i<actions.length ) {
				if( actions[i].id==id )
					actions.splice(i,1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while( i<actions.length ) {
			var a = actions[i];
			a.t -= tmod/Const.FPS;
			if( a.t<=0 ) {
				actions.splice(i,1);
				if( isAlive() )
					a.cb();
			}
			else
				i++;
		}
	}


    public function preUpdate() {
		cd.update(tmod);
		updateActions();
    }

    public function postUpdate() {
        spr.x = (cx+xr)*Const.GRID;
        spr.y = (cy+yr)*Const.GRID;
        spr.scaleX = dir*sprScaleX;
        spr.scaleY = sprScaleY;
		spr.visible = entityVisible;

		if( debugLabel!=null ) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth*0.5);
			debugLabel.y = Std.int(footY+1);
		}
	}

	function onHitWall() {}
	function onStep() {}
	var maxStep = 0.4;
	function physicsUpdate() {
		var steps = M.fabs(dx)<=maxStep ? 1 : M.ceil(M.fabs(dx/maxStep));
		steps = M.imax( steps, M.fabs(dy)<=maxStep ? 1 : M.ceil(M.fabs(dy/maxStep)) );

		for(i in 0...steps) {
			if( destroyed )
				return;

			// X
			xr+=dx/steps;
			if( !ignoreColl ) {
				if( xr>0.8 && level.hasAnyCollision(cx+1,cy) ) {
					game.hud.debug(level.hasAnyCollision(cx+1,cy), true);
					xr = 0.8;
					dx = 0;
					onHitWall();
				}
				if( xr<0.2 && level.hasAnyCollision(cx-1,cy) ) {
					xr = 0.2;
					dx = 0;
					onHitWall();
				}
			}
			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }

			// Y
			yr+=dy/steps;

			if( !ignoreColl ) {
				if( yr>0.8 && level.hasAnyCollision(cx,cy+1) ) {
					yr = 0.8;
					dy = 0;
					onHitWall();
				}
				if( yr<0.2 && level.hasAnyCollision(cx,cy-1) ) {
					yr = 0.2;
					dy = 0;
					onHitWall();
				}
			}
			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }

			onStep();
		}

		dx*=frictX;
		dy*=frictY;
		if( M.fabs(dx)<=0.001 ) dx = 0;
		if( M.fabs(dy)<=0.001 ) dy = 0;
	}

	public function fixedUpdate() {} // runs at a "guaranteed" 30 fps

    public function update() { // runs at an unknown fps
		physicsUpdate();
    }
	
}