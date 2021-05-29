import dn.heaps.assets.Aseprite;
import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;

	/** Main atlas **/
	public static var tiles : SpriteLib;
	public static var bullets : SpriteLib;

	public static var hero : SpriteLib;

	/** Fully typed access to slice names present in Aseprite file (eg. `trace(tilesDict.myStoneTexture)` )**/
	public static var tilesDict = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.tiles);
	public static var bulletDict = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.bullet);

	/** LDtk world data **/
	public static var worldData : World;
	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		// Fonts
		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.barlow_condensed_medium_regular_9.toFont();
		fontSmall = hxd.Res.fonts.barlow_condensed_medium_regular_11.toFont();
		fontMedium = hxd.Res.fonts.barlow_condensed_medium_regular_17.toFont();
		fontLarge = hxd.Res.fonts.barlow_condensed_medium_regular_32.toFont();

		// build sprite atlas directly from Aseprite file
		bullets = Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.bullet.toAseprite());
		bullets.defineAnim("fxBullet","0,1-3");
		tiles = Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
		hero = Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.hero.toAseprite());

		worldData = new World();
	}

}