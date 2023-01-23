package as3isolib.utils
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import flash.display.Sprite;
   import starling.display.Quad;
   import starling.display.Sprite;
   
   public class IsoUtil
   {
      
      public static var flash:Boolean = true;
       
      
      public function IsoUtil()
      {
         super();
      }
      
      public static function createDisplayObjectWrapper(param1:Boolean = false) : DisplayObjectWrapper
      {
         var _loc2_:flash.display.Sprite = null;
         var _loc3_:starling.display.Sprite = null;
         var _loc4_:Quad = null;
         if(!PlatformStarling.instance)
         {
            _loc2_ = new flash.display.Sprite();
            _loc2_.mouseChildren = _loc2_.mouseEnabled = false;
            return new DisplayObjectWrapperFlash(_loc2_);
         }
         _loc3_ = new starling.display.Sprite();
         _loc3_.touchable = false;
         if(param1)
         {
            _loc4_ = new Quad(3,3,16711680);
            _loc3_.addChild(_loc4_);
            _loc4_.x = -1;
            _loc4_.y = -1;
         }
         return new DisplayObjectWrapperStarling(_loc3_);
      }
   }
}
