package engine.saga
{
   public class SagaHeroStats
   {
      
      protected static var instance:SagaHeroStats = null;
       
      
      public function SagaHeroStats()
      {
         super();
      }
      
      public static function setProgress(param1:int) : void
      {
         if(instance)
         {
            instance.internal_setProgress(param1);
         }
      }
      
      public static function setStat(param1:String, param2:Number) : void
      {
         if(instance)
         {
            instance.internal_setStat(param1,param2);
         }
      }
      
      public static function incrementStat(param1:String) : void
      {
         if(instance)
         {
            instance.internal_incrementStat(param1);
         }
      }
      
      protected function internal_setProgress(param1:int) : void
      {
      }
      
      protected function internal_setStat(param1:String, param2:int) : void
      {
      }
      
      protected function internal_incrementStat(param1:String) : void
      {
      }
   }
}
