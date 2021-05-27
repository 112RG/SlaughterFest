package en;

typedef WaveInstruction = {
	var cmd:String;
	var val:Int;
}

class WaveEmitter extends Entity {
	public var seed : Int;
	var running : Bool;
	var count : Int;
	var tickCb : Void->Enemy;
	var freqS : Float;
	public var topTriggerDist = 7;

	public function new(x,y, n:Int, cb:Void->Enemy, freqS=0.7) {
		super(x,y);
		this.freqS = freqS;
		count = Const.INFINITE;
		running = false;
        ignoreColl = false;
		tickCb = cb;
		//seed = cx+cy*lvl.wid;
		seed = cy;

	}

	public inline function makeRand() return new dn.Rand(seed);


	override public function update() {
		super.update();
		spr.visible = false;
		spr.alpha = count>0 ? 1 : 0.5;
		if( !running && count>0  )
			running = true;
		if( running  && Enemy.ALL.length < 3) {
			if( !cd.hasSetS("pop",freqS) ) {
				var e : Enemy = tickCb();
				if( cx<=0 )
					e.setPosPixel(centerX-Const.GRID, centerY);
				else if( cx>=level.cWid-1 )
					e.setPosPixel(centerX+Const.GRID, centerY);
				else
					e.setPosPixel(centerX, centerY);
				//e.wave = this;
				count--;
				if( count<=0 ) {
					running = false;
				}
			}
		}
	}
}