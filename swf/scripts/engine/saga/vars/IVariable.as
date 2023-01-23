package engine.saga.vars
{
   public interface IVariable
   {
       
      
      function get bag() : IVariableBag;
      
      function set bag(param1:IVariableBag) : void;
      
      function get def() : VariableDef;
      
      function get asInteger() : int;
      
      function get asUnsigned() : uint;
      
      function get asNumber() : Number;
      
      function get asBoolean() : Boolean;
      
      function get asString() : String;
      
      function get value() : String;
      
      function set asAny(param1:*) : void;
      
      function set asInteger(param1:int) : void;
      
      function set asNumber(param1:Number) : void;
      
      function set asBoolean(param1:Boolean) : void;
      
      function set asString(param1:String) : void;
      
      function get fullname() : String;
   }
}
