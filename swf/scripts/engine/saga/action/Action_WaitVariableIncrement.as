package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.vars.Variable;
   
   public class Action_WaitVariableIncrement extends Action
   {
       
      
      public function Action_WaitVariableIncrement(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
      }
      
      override public function triggerVariableIncrement(param1:Variable, param2:int) : void
      {
         if(param1.def.name != def.id)
         {
            return;
         }
         var _loc3_:* = param1.asInteger > param2;
         var _loc4_:Number = def.varvalue;
         if(_loc4_ == 0 || _loc4_ >= 0 && _loc3_ || _loc4_ <= 0 && !_loc3_)
         {
            end();
         }
      }
   }
}
