package engine.resource
{
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   
   public interface ILoaderFactory
   {
       
      
      function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader;
   }
}
