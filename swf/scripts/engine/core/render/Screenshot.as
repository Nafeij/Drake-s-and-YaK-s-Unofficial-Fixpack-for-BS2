package engine.core.render
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.util.AppInfo;
   import engine.core.util.BitmapUtil;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.display.Stage;
   
   public class Screenshot
   {
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
      
      public static var EVENT_START:String = "Screenshot.EVENT_START";
      
      public static var EVENT_END:String = "Screenshot.EVENT_END";
      
      private static var scratchRect:Rectangle = new Rectangle();
       
      
      public function Screenshot()
      {
         super();
      }
      
      public static function screenshotPng(param1:DisplayObject, param2:int, param3:int, param4:AppInfo, param5:Boolean) : ByteArray
      {
         var _loc6_:BitmapData = getScreenshotBmp(param1,param2,param3,param4);
         var _loc7_:ByteArray = PngEncoderUtil.pngEncode(_loc6_,param5);
         _loc6_.dispose();
         return _loc7_;
      }
      
      private static function getScreenshotBmp(param1:DisplayObject, param2:int, param3:int, param4:AppInfo) : BitmapData
      {
         var _loc6_:BitmapData = null;
         var _loc7_:Bitmap = null;
         var _loc5_:BitmapData = null;
         if(PlatformStarling.instance)
         {
            _loc5_ = screenshotBitmapDataStarling(param2,param3,param4);
            _loc6_ = screenshotBitmapDataFlash(param1,param2,param3,param4,true);
            _loc7_ = new Bitmap(_loc6_);
            BitmapUtil.drawWithQuality(_loc5_,_loc7_,null,null,null,null,true,StageQuality.LOW);
            _loc6_.dispose();
         }
         else
         {
            _loc5_ = screenshotBitmapDataFlash(param1,param2,param3,param4);
         }
         return _loc5_;
      }
      
      public static function screenshotZipped(param1:DisplayObject, param2:int, param3:int, param4:AppInfo) : ByteArray
      {
         var _loc5_:BitmapData = getScreenshotBmp(param1,param2,param3,param4);
         scratchRect.setTo(0,0,param2,param3);
         var _loc6_:ByteArray = new ByteArray();
         _loc6_.writeInt(_loc5_.width);
         _loc6_.writeInt(_loc5_.height);
         _loc6_.writeBoolean(false);
         _loc6_.writeInt(0);
         _loc5_.copyPixelsToByteArray(scratchRect,_loc6_);
         _loc6_.compress();
         _loc5_.dispose();
         return _loc6_;
      }
      
      public static function zipScreenshot(param1:BitmapData) : ByteArray
      {
         scratchRect.setTo(0,0,param1.width,param1.height);
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeInt(param1.width);
         _loc2_.writeInt(param1.height);
         _loc2_.writeBoolean(false);
         _loc2_.writeInt(0);
         param1.copyPixelsToByteArray(scratchRect,_loc2_);
         _loc2_.compress();
         param1.dispose();
         return _loc2_;
      }
      
      public static function unzipScreenshot(param1:ByteArray) : BitmapData
      {
         param1.position = 0;
         param1.uncompress();
         var _loc2_:int = param1.readInt();
         var _loc3_:int = param1.readInt();
         var _loc4_:Boolean = param1.readBoolean();
         var _loc5_:int = param1.readInt();
         if(_loc5_ > 0)
         {
            param1.position += _loc5_;
         }
         var _loc6_:BitmapData = new BitmapData(_loc2_,_loc3_,_loc4_,0);
         scratchRect.setTo(0,0,_loc2_,_loc3_);
         _loc6_.setPixels(scratchRect,param1);
         return _loc6_;
      }
      
      public static function computeScale(param1:int, param2:int, param3:int, param4:int) : Number
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param3 != 0 && param4 != 0)
         {
            _loc5_ = param3 / param1;
            _loc6_ = param4 / param2;
            return Math.min(_loc5_,_loc6_);
         }
         return 1;
      }
      
      public static function screenshotBitmapDataFlash(param1:DisplayObject, param2:int, param3:int, param4:AppInfo, param5:Boolean = false) : BitmapData
      {
         var _loc7_:Matrix = null;
         var _loc8_:Rectangle = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc6_:BitmapData = null;
         if(param2 != 0 && param3 != 0)
         {
            _loc6_ = new BitmapData(param2,param3,param5,0);
            _loc7_ = new Matrix();
            _loc9_ = computeScale(param1.width,param1.height,param2,param3);
            _loc7_.scale(_loc9_,_loc9_);
            _loc10_ = param1.width * _loc9_;
            _loc11_ = param1.height * _loc9_;
            _loc12_ = (param2 - _loc10_) / 2;
            _loc13_ = (param3 - _loc11_) / 2;
            _loc7_.translate(_loc12_,_loc13_);
            _loc8_ = new Rectangle(_loc12_,_loc13_,_loc10_,_loc11_);
         }
         else
         {
            _loc6_ = new BitmapData(param1.width,param1.height,param5,0);
         }
         dispatcher.dispatchEvent(new Event(EVENT_START));
         BitmapUtil.drawWithQuality(_loc6_,param1,_loc7_,null,null,_loc8_,true,StageQuality.HIGH);
         dispatcher.dispatchEvent(new Event(EVENT_END));
         return _loc6_;
      }
      
      public static function screenshotBitmapDataStarling(param1:int, param2:int, param3:AppInfo) : BitmapData
      {
         var _loc4_:Stage = Starling.current.stage;
         var _loc5_:int = _loc4_.stageWidth;
         var _loc6_:int = _loc4_.stageHeight;
         var _loc7_:Number = computeScale(_loc5_,_loc6_,param1,param2);
         var _loc8_:RenderSupport = new RenderSupport();
         _loc8_.clear(_loc4_.color,1);
         _loc8_.setProjectionMatrix(0,0,_loc5_,_loc6_,_loc5_,_loc6_,_loc4_.cameraPosition);
         _loc4_.render(_loc8_,1);
         _loc8_.finishQuadBatch();
         var _loc9_:BitmapData = new BitmapData(_loc5_,_loc6_,false,0);
         Starling.context.drawToBitmapData(_loc9_);
         _loc8_.dispose();
         var _loc10_:BitmapData = new BitmapData(param1,param2,false,0);
         var _loc11_:Bitmap = new Bitmap(_loc9_);
         var _loc12_:Matrix = new Matrix();
         var _loc13_:Number = (_loc5_ - param1 / _loc7_) / 2;
         var _loc14_:Number = (_loc6_ - param2 / _loc7_) / 2;
         _loc12_.translate(-_loc13_,-_loc14_);
         _loc12_.scale(_loc7_,_loc7_);
         BitmapUtil.drawWithQuality(_loc10_,_loc11_,_loc12_,null,null,null,true,StageQuality.HIGH);
         _loc9_.dispose();
         return _loc10_;
      }
   }
}
