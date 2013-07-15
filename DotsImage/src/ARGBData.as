package  
{
	/**
	 * ...
	 * @author umhr
	 */
	public class ARGBData 
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

}