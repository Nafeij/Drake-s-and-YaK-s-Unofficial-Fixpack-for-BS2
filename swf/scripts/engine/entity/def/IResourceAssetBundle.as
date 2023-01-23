package engine.entity.def
{
   import engine.resource.IResource;
   import engine.resource.IResourceGroup;
   import engine.resource.IResourceManager;
   
   public interface IResourceAssetBundle extends IAssetBundle
   {
       
      
      function addExtraResource(param1:String, param2:Class) : IResource;
      
      function get preloads() : IAssetBundleManager;
      
      function get group() : IResourceGroup;
      
      function get resman() : IResourceManager;
      
      function listenForCompletion() : void;
   }
}
