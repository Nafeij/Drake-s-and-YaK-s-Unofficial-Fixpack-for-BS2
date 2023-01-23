package engine.core.locale
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.SimpleButton;
   import flash.text.TextField;
   
   public class LocaleUtil
   {
       
      
      public function LocaleUtil()
      {
         super();
      }
      
      public static function setText(param1:SimpleButton, param2:String) : void
      {
         checkText(param1.downState as DisplayObjectContainer,param2);
         checkText(param1.hitTestState as DisplayObjectContainer,param2);
         checkText(param1.overState as DisplayObjectContainer,param2);
         checkText(param1.upState as DisplayObjectContainer,param2);
      }
      
      private static function checkText(param1:DisplayObjectContainer, param2:String) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc5_:TextField = null;
         if(!param1)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            _loc4_ = param1.getChildAt(_loc3_);
            _loc5_ = _loc4_ as TextField;
            if(_loc5_)
            {
               _loc5_.text = !!param2 ? param2 : "";
            }
            _loc3_++;
         }
      }
   }
}
