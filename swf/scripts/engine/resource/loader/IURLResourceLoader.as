package engine.resource.loader
{
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class IURLResourceLoader extends IResourceLoader
   {
       
      
      public function IURLResourceLoader(param1:String, param2:IResourceLoaderListener, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      public function get dataFormat() : String
      {
         throw new IllegalOperationError("pure virtual");
      }
   }
}
