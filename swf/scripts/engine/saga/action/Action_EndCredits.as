package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   
   public class Action_EndCredits extends Action
   {
       
      
      public function Action_EndCredits(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:int = def.varvalue;
         var _loc2_:SagaCreditsDef = saga.def.getCreditsDef(_loc1_);
         if(!_loc2_)
         {
            throw new ArgumentError("failure credits index " + _loc1_);
         }
         saga.performEndCredits(_loc2_,true,true);
         end();
      }
   }
}
