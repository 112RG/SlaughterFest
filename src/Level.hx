class Level extends dn.Process {
	var coll : haxe.ds.Vector<Bool>;
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	/** Level grid-based width**/
	public var cWid(get,never) : Int; inline function get_cWid() return 64;

	/** Level grid-based height **/
	public var cHei(get,never) : Int; inline function get_cHei() return 64;

	/** Level pixel width**/
	public var pxWid(get,never) : Int; inline function get_pxWid() return cWid*Const.GRID;

	/** Level pixel height**/
	public var pxHei(get,never) : Int; inline function get_pxHei() return cHei*Const.GRID;


	//public var data : World.World_Level;
	var invalidated = true;
	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
	}

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;
	public inline function hasColl(x,y) return !isValid(x,y) ? true : coll.get( coordId(x,y) );
	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx,cy) return cx + cy*cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}


	function render() {
		// Placeholder level render
		root.removeChildren();
/* 		for(cx in 0...cWid)
			for(cy in 0...cHei) {
				var g = new h2d.Graphics(root);
				g.beginFill( Color.randomColor(rnd(0,1), 0.5, 0.4) );
				g.drawRect(cx*Const.GRID, cy*Const.GRID, cWid, cHei);
			} */
		var w = new en.WaveEmitter(12,12, 12, function() return new en.Enemy(0,0), 0.25);
		var r = w.makeRand();
		w.topTriggerDist = r.irange(3,6);
	
		//g.beginFill( 0xffcc00 );
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}