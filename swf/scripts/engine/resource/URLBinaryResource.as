package engine.resource
{
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import engine.resource.loader.URLResourceLoader;
   
   public class URLBinaryResource extends URLResource implements ILoaderFactory
   {
       
      
      public function URLBinaryResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3 != null ? param3 : this);
      }
      
      override public function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader
      {
         return new URLResourceLoader(param1,param2,logger,true);
      }
   }
}
