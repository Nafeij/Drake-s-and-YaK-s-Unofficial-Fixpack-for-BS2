package engine.gui.core
{
   public class EngineEnum
   {
       
      
      private var _name:String;
      
      private var _value:int;
      
      private var _registry:EngineEnumRegistry;
      
      public function EngineEnum(param1:String, param2:int, param3:EngineEnumRegistry)
      {
         super();
         this._registry = param3;
         this._name = param1;
         this._value = param2;
         param3.register(this);
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function toString() : String
      {
         return "[" + this._registry.name + ": " + this._name + " (" + this._value + ")]";
      }
   }
}
