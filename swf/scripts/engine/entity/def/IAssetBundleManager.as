package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.resource.IResourceManager;
   
   public interface IAssetBundleManager
   {
       
      
      function cleanup() : void;
      
      function get id() : String;
      
      function get resman() : IResourceManager;
      
      function get logger() : ILogger;
      
      function registerBundle(param1:IResourceAssetBundle) : void;
      
      function getDebugListing() : String;
      
      function getDebugInfo(param1:String) : String;
      
      function toString() : String;
      
      function purge() : void;
   }
}
