package engine.saga
{
   import engine.core.analytic.Ga;
   
   public class SagaCheat
   {
      
      public static var instance:ISaga;
       
      
      public function SagaCheat()
      {
         super();
      }
      
      public static function devCheat(param1:String) : void
      {
         Ga.stop(param1);
         if(instance)
         {
            if(!instance.isDevCheat)
            {
               if(!instance.isDebugger)
               {
                  instance.logger.info("CHEATED with " + param1);
               }
            }
            if(!instance.isDebugger)
            {
               instance.setVar("dev_cheat",true);
            }
            instance.devBookmarked = true;
         }
      }
   }
}
