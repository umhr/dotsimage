package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author umhr
	 */
	[SWF(width = 465, height = 465, backgroundColor = 0xFFFFFF, frameRate = 30)]
	public class WonderflMain extends Sprite 
	{
		
		public function WonderflMain():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//stage.scaleMode = "noScale";
			//stage.align = "TL";
			
			var canvas:Canvas = new Canvas();
			addChild(canvas);
			canvas.x = int((stage.stageWidth - 640) * 0.5);
			canvas.y = int((stage.stageHeight - 480) * 0.5);
		}
		
	}
	
}

	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author umhr
	 */
	 class Canvas extends Sprite 
	{
		private var circleCanvas:Shape = new Shape();
		public function Canvas() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			setUp();
			
			//var loader:Loader = new Loader();
			//loader.load(new URLRequest("gomacha.jpg"));
			//loader.load(new URLRequest("Frog320x240.jpg"));
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			//addChild(bitmaCanvas);
			
			addChild(circleCanvas);
		}
		
		private function setUp():void 
		{
			addChild(CameraManager.getInstance());
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			CameraManager.getInstance().enter();
			
			draw(CameraManager.getInstance().getBitmapData());
		}
		
		//private function loader_complete(e:Event):void 
		//{
			//var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			//
			//if (loaderInfo.contentType.substr(0,6) == "image/") {
				//var bitmap:Bitmap = loaderInfo.content as Bitmap;
				//bitmap.x = 400;
				//addChild(bitmap);
				//draw(bitmap.bitmapData);
			//}
		//}
		
		private function draw(bitmapData:BitmapData):void 
		{
			var scale:Number = 0.1;
			var miniBitmapData:BitmapData = new BitmapData(320 * scale, 240 * scale);
			miniBitmapData.draw(new Bitmap(bitmapData), new Matrix(scale, 0, 0, scale));
			
			//var bitmap:Bitmap = new Bitmap(miniBitmapData);
			//bitmap.scaleX = bitmap.scaleY = 1 / scale;
			//bitmap.y = 260;
			//addChild(bitmap);
			
			circleCanvas.graphics.clear();
			circleCanvas.graphics.beginFill(0xffffff, 0.2);
			circleCanvas.graphics.drawRect(0, 0, 320 * 2, 240 * 2);
			circleCanvas.graphics.endFill();
			
			serch(miniBitmapData);
		}
		
		/**
		 * 
		 * @param	miniBitmapData
		 */
		private function serch(miniBitmapData:BitmapData):void 
		{
			var w:int = miniBitmapData.width;
			var h:int = miniBitmapData.height;
			
			var checkList:Vector.<Boolean> = new Vector.<Boolean>(w * h);
			
			for (var i:int = 0; i < h; i++) 
			{
				for (var j:int = 0; j < w; j++) 
				{
					if(!checkList[i * w + j]){
						var resultAR:Array = circleCheck(i, j, h, w, 1, miniBitmapData, checkList);
						var circleSize:int = resultAR[0];
						var circleRGB:int = resultAR[1];
						drawCircle(circleRGB, circleSize, w, i, j, checkList);
					}
				}
			}
		}
		
		/**
		 * 近い色で正方形をどこまで作れるかを探索します。
		 * @param	i
		 * @param	j
		 * @param	h
		 * @param	w
		 * @param	size
		 * @param	miniBitmapData
		 * @param	checkList
		 * @return	[size,rgb];
		 */
		private function circleCheck(i:int, j:int, h:int, w:int, size:int, miniBitmapData:BitmapData, checkList:Vector.<Boolean>):Array {
			var maxSize:int = 24; // 最小単位から何倍の大きさまで探査するか。小さくすると、全体的に小さな円で描かれる。
			var tolerance:int = 40; // 色の距離の許容度。小さくすると、色の差にシビアになる。
			var result:Array = [];
			
			var nearResult:Array;
			if(size == 1){
				nearResult = [0, miniBitmapData.getPixel(j, i)];
			}else {
				nearResult = nearColor(miniBitmapData.getVector(new Rectangle(j, i, size, size)));
			}
			
			if (nearResult[0] < tolerance) {
				result[0] = size;
				result[1] = nearResult[1];
				
				if (size < maxSize ) {
					if ((i < h - size) && (j < w - size) && !(j < w - size && checkList[i * w + j + size])) {
						var resultAR:Array = circleCheck(i, j, h, w, size + 1, miniBitmapData, checkList);
						if (resultAR.length > 0) {
							result[0] = resultAR[0];
							result[1] = resultAR[1];
						}
					}
				}
			}
			return result;
		}
		
		/**
		 * 円を描画します。
		 * @param	rgb
		 * @param	size
		 * @param	w
		 * @param	ti
		 * @param	tj
		 * @param	checkList
		 */
		private function drawCircle(rgb:int, size:int, w:int, ti:int, tj:int, checkList:Vector.<Boolean>):void {
			
			// 彩度を二倍に
			var argbData:ARGBData = new ARGBData();
			argbData.setByRGBUINT(rgb);
			rgb = argbData.getRGBBySaturation(2);
			
			// 円を描く
			//circleCanvas.graphics.lineStyle(0, 0xFFFFFF);
			circleCanvas.graphics.beginFill(rgb);
			//circleCanvas.graphics.drawCircle(10 * (tj + 0.5 * size), 10 * (ti + 0.5 * size), 5 * size);
			circleCanvas.graphics.drawCircle(20 * (tj + 0.5 * size), 20 * (ti + 0.5 * size), 10 * size);
			//circleCanvas.graphics.drawCircle(30 * (tj + 0.5 * size), 30 * (ti + 0.5 * size), 15 * size);
			circleCanvas.graphics.endFill();
			
			// 同じ場所に二重に描かないようにフラグを立てる。
			for (var i:int = 0; i < size; i++) 
			{
				for (var j:int = 0; j < size; j++) 
				{
					checkList[(ti + i) * w + tj + j] = true;
				}
			}
		}
		
		/**
		 * 色の近さを取得します。
		 * 
		 * @param	pixels
		 * @return	[average, rgb] 平均色からの平均距離、平均色
		 */
		private function nearColor(pixels:Vector.<uint>):Array 
		{
			var argbDataList:Vector.<ARGBData> = new Vector.<ARGBData>();
			var averageRGB:ARGBData = new ARGBData();
			
			// 色を取り出し、平均色を求める。
			var n:int = pixels.length;
			for (var i:int = 0; i < n; i++) 
			{
				var argbData:ARGBData = new ARGBData().setByUINT(pixels[i]);
				argbDataList[i] = argbData;
				averageRGB.r += argbData.r / n;
				averageRGB.g += argbData.g / n;
				averageRGB.b += argbData.b / n;
			}
			
			// 平均色からの距離を求める。知覚的な距離をつかう。
			var average:uint = 0;
			for (i = 0; i < n; i++) 
			{
				average += averageRGB.distanceByNTSCCoefficients(argbDataList[i]);
				//average += averageRGB.distance(argbDataList[i]);
			}
			average /= n;
			
			return [average, averageRGB.rgb];
		}
		
	}
	
	/**
	 * ...
	 * @author umhr
	 */
	 class ARGBData 
	{
		public var a:int;
		public var r:int;
		public var g:int;
		public var b:int;
		public var h:Number;
		public var s:Number;
		public var v:Number;
		public function ARGBData() 
		{
			
		}
		
		public function setByUINT(argb:uint):ARGBData {
			a = argb >> 24;//24bit右にずらす。
			r = argb >> 16 & 0xff;//16bit右にずらして、下位8bitのみを取り出す。
			g = argb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
			b = argb & 0xff;//下位8bitのみを取り出す。
			return this;
		}
		
		public function setByRGBUINT(rgb:uint):ARGBData {
			a = 0xFF;
			r = rgb >> 16 & 0xff;//16bit右にずらして、下位8bitのみを取り出す。
			g = rgb >> 8 & 0xff;//8bit右にずらして、下位8bitのみを取り出す。
			b = rgb & 0xff;//下位8bitのみを取り出す。
			return this;
		}
		
		public function distance(argbData:ARGBData):uint {
			var result:uint = 0;
			result += Math.abs(a - argbData.a);
			result += Math.abs(r - argbData.r);
			result += Math.abs(g - argbData.g);
			result += Math.abs(b - argbData.b);
			return result;
		}
		
		/**
		 * NTSC 係数による加重平均法 ( NTSC Coef. method )
		 * NTSC Coefficients
		 * @param	argbData
		 * @return
		 */
		public function distanceByNTSCCoefficients(argbData:ARGBData):uint {
			var result:uint = 0;
			result += Math.abs(a - argbData.a);
			result += Math.abs(r - argbData.r) * 0.298912 * 3.333;
			result += Math.abs(g - argbData.g) * 0.586611 * 3.333;
			result += Math.abs(b - argbData.b) * 0.114478 * 3.333;
			return result;
		}
		
		public function getRGBBySaturation(d:Number):int {
			setHSV();
			s = Math.min(s * d, 1);
			setRGBbyHSV();
			
			return r << 16 | g << 8 | b;
		}
		
		/**
		 * http://imagingsolution.net/imaging/hue-saturation-brightness-formula
		 */
		public function setHSV():void {
			var iMax:Number = Math.max(r, g, b);
			var iMin:Number = Math.min(r, g, b);
			if(iMax == r){
				h = 60 * (g - b) / (iMax - iMin);
			}else if (iMax == g) {
				h = 60 * (b - r) / (iMax - iMin) + 120;
			}else {
				h = 60 * (r - g) / (iMax - iMin) + 240;
			}
			s = (iMax - iMin) / iMax;
			v = iMax;
		}
		
		public function setRGBbyHSV():void {
			
			if (s == 0) {
				r = g = b = v;
				return;
			}
			
			
			var xH:int = Math.floor(h / 60);
			var xP:Number = v * (1 - s);
			var xQ:Number = v * (1 - s * (h / 60 - xH));
			var xT:Number = v * (1 - s * (1 - (h / 60 - xH)));
			switch (xH) 
			{
				case 0:
					r = v;
					g = xT;
					b = xP;
				break;
				case 1:
					r = xQ;
					g = v;
					b = xP;
				break;
				case 2:
					r = xP;
					g = v;
					b = xT;
				break;
				case 3:
					r = xP;
					g = xQ;
					b = v;
				break;
				case 4:
					r = xT;
					g = xP;
					b = v;
				break;
				case 5:
					r = v;
					g = xP;
					b = xQ;
				break;
				default:
			}
			
			
		}
		
		public function get rgb():int {
			return r << 16 | g << 8 | b;
		}
		
		public function clone():ARGBData {
			var result:ARGBData = new ARGBData();
			result.a = a;
			result.r = r;
			result.g = g;
			result.b = b;
			return result;
		}
		
		public function toString():String {
			var result:String = "ARGBData:{";
			result += "a:" + a + ",";
			result += "r:" + r + ",";
			result += "g:" + g + ",";
			result += "b:" + b + "";
			result += "}";
			return result;
		}
		
	}

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.media.Camera;
	import flash.media.Video;
	/**
	 * ...
	 * @author umhr
	 */
	 class CameraManager extends Sprite
	{
		private static var _instance:CameraManager;
		public function CameraManager(block:SingletonBlock){init();}
		public static function getInstance():CameraManager{
			if ( _instance == null ) {_instance = new CameraManager(new SingletonBlock());};
			return _instance;
		}
		
		private var _video:Video = new Video();
		private var _bitmapData:BitmapData;
		private var _scale:Number = 1;
		public var activating:Boolean = false;
		private var _count:uint = 0;
		private var _dx:Number = 0;
		private var _dy:Number = 0;
		private function init():void
		{
            if (stage) onInit();
            else addEventListener(Event.ADDED_TO_STAGE, onInit);
        }
        
        private function onInit(event:Event = null):void 
        {
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			var camera:Camera = Camera.getCamera();
			//カメラの存在を確認
			if (camera) {
				camera.setMode(160, 120, 30);
				camera.addEventListener(ActivityEvent.ACTIVITY, camera_activity);
				_video.attachCamera(camera);
				_scale = Math.min(320 / stage.stageWidth, 240 / stage.stageHeight);
				_dx = (320 - stage.stageWidth * _scale) * 0.5;
				_dy = (240 - stage.stageHeight * _scale) * 0.5;
				
				_video.scaleX = 2;
				_video.scaleY = 2;
				_video.filters = [new BlurFilter(16, 16)];
				addChild(_video);
				
				_bitmapData = new BitmapData(320, 240);
			} else {
				trace("カメラが見つかりませんでした。");
			}
		}
		
		private function camera_activity(event:ActivityEvent):void 
		{
			activating = true;
		}
		
		/**
		 * カメラで取得した結果を_bitmapDataに保持する。
		 */
		public function enter():void {
			if (!activating) { return };
			if (_count % 4 == 0) {
				_bitmapData.draw(_video);
			}
			_count ++;
		}
		
		public function getBitmapData():BitmapData {
			return _bitmapData;
		}
		
		/**
		 * 対応する座標の色を返す。
		 * @param	x
		 * @param	y
		 * @return
		 */
		public function getPixel(x:int, y:int):int {
			if (!activating) { return 0x0 };
			var tx:int = x * _scale + _dx;
			var ty:int = y * _scale + _dy;
			return _bitmapData.getPixel(tx, ty);
		}
		
		public function get video():Video 
		{
			return _video;
		}
	}
	

class SingletonBlock { };