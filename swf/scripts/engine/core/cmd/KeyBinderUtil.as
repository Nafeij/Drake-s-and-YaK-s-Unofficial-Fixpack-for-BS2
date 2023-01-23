package engine.core.cmd
{
   public class KeyBinderUtil
   {
       
      
      public function KeyBinderUtil()
      {
         super();
      }
      
      public static function makeBinding(param1:Boolean, param2:Boolean, param3:Boolean, param4:uint) : String
      {
         var _loc5_:* = "";
         if(param1)
         {
            _loc5_ += "ctrl+";
         }
         if(param2)
         {
            _loc5_ += "alt+";
         }
         if(param3)
         {
            _loc5_ += "shift+";
         }
         return _loc5_ + param4;
      }
      
      public static function makeBindingUp(param1:uint) : String
      {
         return param1.toString() + " up";
      }
   }
}
