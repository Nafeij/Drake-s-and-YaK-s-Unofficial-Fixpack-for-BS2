package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.IRefcount;
   
   public interface IAssetBundle extends IRefcount
   {
       
      
      function get bundles() : Vector.<IAssetBundle>;
      
      function addBundle(param1:IAssetBundle) : void;
      
      function get isReleased() : Boolean;
      
      function get id() : String;
      
      function get logger() : ILogger;
      
      function cleanup() : void;
      
      function getDebugSummaryLine() : String;
      
      function getDebugInfo() : String;
   }
}
