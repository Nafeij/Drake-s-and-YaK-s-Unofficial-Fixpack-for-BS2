package engine.saga.vars
{
   import engine.expression.ISymbols;
   
   public interface IVariableProvider extends ISymbols
   {
       
      
      function getVar(param1:String, param2:VariableType) : IVariable;
      
      function setVar(param1:String, param2:*) : IVariable;
      
      function getVarBool(param1:String) : Boolean;
      
      function getVarString(param1:String) : String;
      
      function getVarInt(param1:String) : int;
      
      function getVarNumber(param1:String) : Number;
      
      function enumerateVarsNames(param1:Vector.<String>) : Vector.<String>;
      
      function removeVar(param1:String) : void;
   }
}
