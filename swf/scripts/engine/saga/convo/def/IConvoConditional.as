package engine.saga.convo.def
{
   public interface IConvoConditional
   {
       
      
      function getConditions() : ConvoConditionsDef;
      
      function addIfCondition(param1:String) : void;
   }
}
