package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_EnableSnow extends Action
   {
       
      
      public function Action_EnableSnow(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         saga.performEnableSceneWeather(_loc1_);
         end();
      }
   }
}
