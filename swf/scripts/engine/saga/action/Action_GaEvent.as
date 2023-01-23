package engine.saga.action
{
   import engine.core.analytic.Ga;
   import engine.saga.Saga;
   import engine.saga.vars.IVariable;
   
   public class Action_GaEvent extends Action
   {
       
      
      public function Action_GaEvent(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc5_:IVariable = null;
         var _loc1_:String = def.id;
         var _loc2_:String = def.param;
         var _loc3_:String = def.location;
         var _loc4_:int = def.varvalue;
         _loc2_ = saga.performStringReplacement_SagaVar(_loc2_);
         _loc3_ = saga.performStringReplacement_SagaVar(_loc3_);
         if(def.varother)
         {
            _loc5_ = saga.getVar(def.varother,null);
            if(!_loc5_)
            {
               logger.error("Action_GaEvent no such varother: " + def.varother + " for " + this);
            }
            else
            {
               _loc4_ = _loc5_.asInteger;
            }
         }
         Ga.normal(_loc1_,_loc2_,_loc3_,_loc4_);
         end();
      }
   }
}
