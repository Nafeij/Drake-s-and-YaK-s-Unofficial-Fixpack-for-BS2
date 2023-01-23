package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_EnableClickable extends Action
   {
       
      
      public function Action_EnableClickable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = this.toString();
         var _loc2_:* = def.varvalue != 0;
         if(def.expression)
         {
            if(!def.exp_expression)
            {
               throw new ArgumentError("Action expression is unavailable for evaluation.  See earlier errors on loading: " + this);
            }
            _loc2_ = def.exp_expression.evaluate(saga,true) != 0;
         }
         saga.performEnableSceneElement(_loc2_,def.id,false,true,def.time,_loc1_);
         end();
      }
   }
}
