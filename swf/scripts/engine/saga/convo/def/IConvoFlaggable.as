package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   
   public interface IConvoFlaggable
   {
       
      
      function addFlagFromString(param1:String, param2:ILogger) : void;
   }
}
