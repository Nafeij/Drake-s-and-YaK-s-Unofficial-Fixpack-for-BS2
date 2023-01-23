package engine.saga
{
   import flash.utils.Dictionary;
   
   public class SagaConfig
   {
      
      public static var FORCE_VARS:Dictionary;
       
      
      public function SagaConfig()
      {
         super();
      }
      
      public static function addForceVars(param1:String, param2:*) : void
      {
         if(!FORCE_VARS)
         {
            FORCE_VARS = new Dictionary();
         }
         FORCE_VARS[param1] = param2;
      }
   }
}
