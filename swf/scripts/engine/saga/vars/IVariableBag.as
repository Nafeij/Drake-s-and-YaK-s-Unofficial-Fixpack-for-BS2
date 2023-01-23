package engine.saga.vars
{
   import engine.core.logging.ILogger;
   import engine.saga.IVariableDefProvider;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public interface IVariableBag extends IEventDispatcher
   {
       
      
      function fetch(param1:String, param2:VariableType) : IVariable;
      
      function add(param1:IVariable) : void;
      
      function fromDictionary(param1:Dictionary, param2:ILogger) : void;
      
      function toDictionary(param1:ILogger) : Dictionary;
      
      function debugPrintLog(param1:ILogger, param2:String) : void;
      
      function fromDictionaryKey(param1:String, param2:String, param3:Dictionary, param4:ILogger, param5:Boolean) : IVariable;
      
      function incrementVar(param1:String, param2:int) : void;
      
      function resetAll() : void;
      
      function get vars() : Dictionary;
      
      function get owner() : IVariableDefProvider;
      
      function get name() : String;
      
      function handleVariableChange(param1:IVariable, param2:String) : void;
      
      function getVarInt(param1:String) : int;
      
      function getVarBool(param1:String) : Boolean;
      
      function removeVar(param1:IVariable) : void;
   }
}
