package engine.resource
{
   import engine.core.locale.LocaleId;
   import engine.core.logging.ILogger;
   
   public interface IResourceManager
   {
       
      
      function getResource(param1:String, param2:Class, param3:IResourceGroup = null, param4:Function = null, param5:Boolean = false) : IResource;
      
      function get logger() : ILogger;
      
      function getLocaleId() : LocaleId;
   }
}
