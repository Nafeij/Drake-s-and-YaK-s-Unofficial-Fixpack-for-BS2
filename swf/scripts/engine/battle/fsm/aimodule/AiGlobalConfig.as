package engine.battle.fsm.aimodule
{
   public class AiGlobalConfig
   {
      
      public static var DEBUG:Boolean;
      
      public static var FAST:Boolean;
      
      public static var MAX_THINK_MS:int = 15;
      
      public static var FAST_THINK_FACTOR:Number = 8;
      
      public static var MIN_THINK_MS:int = 5;
      
      public static var INCR_THINK_MS:Number = 0.2;
      
      public static var EAGER:Boolean = false;
      
      public static var UNWILLING:Boolean = false;
      
      private static var FAST_MAX_THINK_MS:int = MAX_THINK_MS * FAST_THINK_FACTOR;
       
      
      public function AiGlobalConfig()
      {
         super();
      }
      
      public static function get maxThinkTimeMs() : Number
      {
         return FAST ? FAST_MAX_THINK_MS : MAX_THINK_MS;
      }
      
      public static function get minThinkTimeMs() : Number
      {
         return FAST ? FAST_MAX_THINK_MS : MIN_THINK_MS;
      }
   }
}
