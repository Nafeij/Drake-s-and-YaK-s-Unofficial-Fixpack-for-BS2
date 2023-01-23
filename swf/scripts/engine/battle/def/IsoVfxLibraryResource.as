package engine.battle.def
{
   import engine.resource.AnimClipResource;
   import engine.resource.ILoaderFactory;
   import engine.resource.Resource;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.vfx.VfxLibrary;
   import engine.vfx.VfxLibraryVars;
   
   public class IsoVfxLibraryResource extends DefResource
   {
       
      
      public var library:VfxLibrary;
      
      public function IsoVfxLibraryResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         var _loc1_:Resource = null;
         var _loc2_:String = null;
         super.internalOnLoadComplete();
         if(jo)
         {
            this.library = new VfxLibraryVars(url,jo,logger);
            this.library.resolve(resourceManager);
            for each(_loc1_ in this.library.groupResources)
            {
               addChild(_loc1_.url,AnimClipResource);
            }
            for each(_loc2_ in this.library.inheritUrls)
            {
               addChild(_loc2_,IsoVfxLibraryResource);
            }
         }
      }
      
      override protected function internalOnLoadedAllComplete() : void
      {
         var _loc1_:String = null;
         var _loc2_:IsoVfxLibraryResource = null;
         if(Boolean(this.library) && Boolean(this.library.inheritUrls))
         {
            for each(_loc1_ in this.library.inheritUrls)
            {
               _loc2_ = resourceManager.getResource(_loc1_,IsoVfxLibraryResource) as IsoVfxLibraryResource;
               _loc2_.release();
               this.library.inherits.push(_loc2_.library);
            }
         }
      }
      
      override protected function internalUnload() : void
      {
         if(this.library)
         {
            this.library.cleanup();
            this.library = null;
         }
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
   }
}
