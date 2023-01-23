package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   
   public class Action_VariableModify extends Action
   {
       
      
      public function Action_VariableModify(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:IVariable = null;
         var _loc5_:Number = NaN;
         if(!def.varname)
         {
            throw new ArgumentError("No varname for " + this);
         }
         var _loc1_:IVariable = saga.getVar(def.varname,VariableType.DECIMAL);
         var _loc2_:Number = def.varvalue;
         var _loc3_:String = !!def.param ? def.param : "+";
         if(def.varother)
         {
            _loc4_ = saga.getVar(def.varother,null);
            if(_loc4_)
            {
               _loc2_ = _loc4_.asNumber;
            }
         }
         if(_loc1_)
         {
            saga.suppressVariableFlytext = def.suppress_flytext;
            _loc5_ = _loc1_.asNumber;
            switch(_loc3_)
            {
               case "+":
                  _loc5_ += _loc2_;
                  break;
               case "-":
                  _loc5_ -= _loc2_;
                  break;
               case "*":
                  _loc5_ *= _loc2_;
                  break;
               case "/":
                  _loc5_ /= _loc2_;
                  break;
               case "%":
                  _loc5_ %= _loc2_;
                  break;
               default:
                  throw new ArgumentError("Invalid operation [" + _loc3_ + "].  Must be one of [+ - * / %]");
            }
            saga.setVar(def.varname,_loc5_);
            saga.suppressVariableFlytext = false;
         }
         end();
      }
   }
}
