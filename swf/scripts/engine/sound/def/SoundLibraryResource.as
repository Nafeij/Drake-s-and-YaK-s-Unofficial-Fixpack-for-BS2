package engine.sound.def
{
   import engine.resource.ILoaderFactory;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   
   public class SoundLibraryResource extends DefResource
   {
       
      
      public var library:SoundLibrary;
      
      public function SoundLibraryResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         var _loc1_:String = null;
         super.internalOnLoadComplete();
         this.library = new SoundLibraryVars(this.url,jo,logger);
         if(this.library.errors)
         {
            logger.error("Sound Library had errors " + url);
         }
         for each(_loc1_ in this.library.inheritUrls)
         {
            addChild(_loc1_,SoundLibraryResource);
         }
      }
      
      override protected function internalOnLoadedAllComplete() : void
      {
         var _loc1_:String = null;
         var _loc2_:SoundLibraryResource = null;
         if(Boolean(this.library) && Boolean(this.library.inheritUrls))
         {
            for each(_loc1_ in this.library.inheritUrls)
            {
               _loc2_ = resourceManager.getResource(_loc1_,SoundLibraryResource) as SoundLibraryResource;
               this.library.inherits.push(_loc2_.library);
            }
         }
      }
      
      override protected function internalUnload() : void
      {
         this.library = null;
         super.internalUnload();
      }
   }
}
