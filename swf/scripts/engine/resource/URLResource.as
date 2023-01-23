package engine.resource
{
   import engine.resource.loader.IResourceLoader;
   import engine.resource.loader.IResourceLoaderListener;
   import engine.resource.loader.IURLResourceLoader;
   import engine.resource.loader.URLResourceLoader;
   
   public class URLResource extends Resource implements ILoaderFactory
   {
       
      
      public function URLResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,null != param3 ? param3 : this);
      }
      
      public function loaderFactoryHandler(param1:String, param2:IResourceLoaderListener) : IResourceLoader
      {
         return new URLResourceLoader(param1,param2,logger,false,false,_unrequired);
      }
      
      public function get data() : *
      {
         return !!loader ? loader.data : null;
      }
      
      public function get dataFormat() : *
      {
         var _loc1_:IURLResourceLoader = loader as IURLResourceLoader;
         if(_loc1_)
         {
            return _loc1_.dataFormat;
         }
         return null;
      }
      
      override protected function handleProcessedLoadCompletion() : void
      {
         releaseLoader();
      }
   }
}
