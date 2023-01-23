package engine.core.fsm
{
   import flash.utils.Dictionary;
   
   public class StateData
   {
       
      
      public var values:Dictionary;
      
      public function StateData()
      {
         this.values = new Dictionary();
         super();
      }
      
      public function getValue(param1:StateDataEnum) : *
      {
         return this.values[param1];
      }
      
      public function setValue(param1:StateDataEnum, param2:*) : void
      {
         this.values[param1] = param2;
      }
      
      public function hasValue(param1:StateDataEnum) : Boolean
      {
         return this.values[param1] != undefined;
      }
      
      public function removeValue(param1:StateDataEnum) : void
      {
         delete this.values[param1];
      }
   }
}
