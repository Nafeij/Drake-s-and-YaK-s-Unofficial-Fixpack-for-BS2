package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.vars.IVariable;
   
   public class Action_VariableSet extends Action
   {
       
      
      public function Action_VariableSet(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:IVariable = null;
         var _loc1_:* = undefined;
         if(def.expression)
         {
            logger.info("Action_VariableSet expression [" + def.expression + "]");
            if(!def.exp_expression)
            {
               throw new ArgumentError("Action expression is unavailable for evaluation.  See earlier errors on loading: " + this);
            }
            _loc1_ = def.exp_expression.evaluate(saga,true);
            if(logger.isDebugEnabled)
            {
               logger.debug("Action_VariableSet exp " + _loc1_ + "=[" + def.exp_expression.toStringRecursive() + "]");
            }
         }
         else
         {
            _loc1_ = !!def.param ? def.param : def.varvalue;
            if(def.varother)
            {
               _loc2_ = saga.getVar(def.varother,null);
               if(!_loc2_)
               {
                  saga.logger.error("Action invalid varother: " + this);
               }
               else
               {
                  _loc1_ = _loc2_.value;
               }
            }
         }
         if(!def.varname)
         {
            saga.logger.error("Action empty varname: " + this);
         }
         else
         {
            saga.suppressVariableFlytext = def.suppress_flytext;
            saga.setVar(def.varname,_loc1_);
            saga.suppressVariableFlytext = false;
         }
         end();
      }
   }
}
