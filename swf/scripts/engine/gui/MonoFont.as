package engine.gui
{
   import engine.core.util.StringUtil;
   import flash.system.Capabilities;
   
   public class MonoFont
   {
      
      public static var FONT:String;
       
      
      public function MonoFont()
      {
         super();
      }
      
      public static function init() : void
      {
         if(StringUtil.startsWith(Capabilities.os,"Mac"))
         {
            FONT = "Monaco";
         }
         else if(StringUtil.startsWith(Capabilities.os,"Windows"))
         {
            FONT = "Consolas";
         }
         else if(StringUtil.startsWith(Capabilities.os,"Linux"))
         {
            FONT = "Courier";
         }
         else if(StringUtil.startsWith(Capabilities.os,"iP"))
         {
            FONT = "Courier New";
         }
      }
   }
}
