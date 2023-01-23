package engine.gui.core
{
   import flash.utils.Dictionary;
   
   public class EngineEnumRegistry
   {
       
      
      private var values:Dictionary;
      
      private var names:Dictionary;
      
      public var name:String;
      
      public function EngineEnumRegistry(param1:String)
      {
         this.values = new Dictionary();
         this.names = new Dictionary();
         super();
         this.name = param1;
      }
      
      public function register(param1:EngineEnum) : void
      {
         this.values[param1.value] = param1;
         this.names[param1.name] = param1;
      }
      
      public function get numValues() : int
      {
         return this.values.length;
      }
      
      public function byValue(param1:int) : EngineEnum
      {
         return this.values[param1];
      }
      
      public function byName(param1:String) : EngineEnum
      {
         return this.names[param1];
      }
   }
}
