import hxsl.Cache;
import en.Hero;
import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx : Fx;

	/** Basic viewport control **/
	public var camera : Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** Level data **/
	public var level : Level;

	/** UI **/
	public var hud : ui.Hud;

	public var hero : en.Hero;

	public var debug : ui.Console;

	public var score : Int;
	var scoreTf : h2d.Text;
	var healthTf : h2d.Text;
	var c : ui.Console;
	public function new() {
		super(Main.ME);

		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect
		score = 0;
		camera = new Camera();

		level = new Level(Assets.worldData.levels[Assets.worldData.all_levels.Level_0.arrayIndex]);
		fx = new Fx();
		hud = new ui.Hud();
		debug = new ui.Console(Assets.fontTiny, root); // init debug console
		Process.resizeAll();
		trace(Lang.t._("Game is ready."));
		hero = new en.Hero();

		scoreTf = new h2d.Text(Assets.fontLarge);
		healthTf = new h2d.Text(Assets.fontLarge);

		root.add(scoreTf, Const.DP_UI);
		root.add(healthTf, Const.DP_UI);

		scoreTf.x = 5;
		healthTf.x = 5;
		healthTf.y = Assets.fontLarge.lineHeight;
		addScore(0);
		addHealth(hero.life);
	}

	public function addScore(?e:Entity, v) {
		score+=v;
		scoreTf.text = "SCORE: "+ dn.Lib.leadingZeros(score, 6);
		if( e!=null ) {
			var tf = new h2d.Text(Assets.fontLarge);
			scroller.add(tf, Const.DP_UI);
			tf.text = ""+v;
			tf.setPosition(e.centerX-tf.textWidth*0.5, e.centerY-tf.textHeight*0.5);
			tw.createMs(tf.alpha, 500|0, TEaseIn, 400).end( tf.remove );
		}
	}
	public function addHealth(v:Int) {
		healthTf.text = "HEALTH: "+ hero.life;
	}
	/** CDB file changed on disk**/
	public function onCdbReload() {}


	/** Window/app resize event **/
	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}


	/** Garbage collect any Entity marked for destruction **/
	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	/** Called if game is destroyed, but only at the end of the frame **/
	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	/** Loop that happens at the beginning of the frame **/
	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	/** Loop that happens at the end of the frame **/
	override function postUpdate() {
		super.postUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();
	}

	/** Main loop but limited to 30fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	/** Main loop **/
	override function update() {
		super.update();
		

		for(e in Entity.ALL) if( !e.destroyed ) e.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(K.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			if( ca.isKeyboardPressed(K.TAB))
				debug.show();
			#end

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();
		}
	}
}

