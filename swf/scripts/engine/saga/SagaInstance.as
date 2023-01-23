package engine.saga
{
   public class SagaInstance
   {
      
      public static var instance:ISaga;
       
      
      public function SagaInstance()
      {
         super();
      }
      
      public static function setSaga(param1:ISaga) : void
      {
         instance = param1;
      }
      
      public static function get isSurvival() : Boolean
      {
         return Boolean(instance) && instance.isSurvival;
      }
   }
}
