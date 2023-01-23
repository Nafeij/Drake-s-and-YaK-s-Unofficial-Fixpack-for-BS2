package engine.battle.def
{
   import engine.anim.def.AnimLibrary;
   import engine.anim.def.AnimLibraryVars;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.resource.AnimClipResource;
   import engine.resource.ILoaderFactory;
   import engine.resource.Resource;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   
   public class IsoAnimLibraryResource extends DefResource
   {
       
      
      private var _library:AnimLibrary;
      
      public function IsoAnimLibraryResource(param1:String, param2:ResourceManager, param3:ILoaderFactory)
      {
         super(param1,param2,param3);
      }
      
      override protected function internalOnLoadComplete() : void
      {
         var _loc1_:Resource = null;
         super.internalOnLoadComplete();
         if(jo)
         {
            this._library = new AnimLibraryVars(url,jo,BattleFacing,logger,null,null);
            if(this._library.errors)
            {
               throw new ArgumentError("Anim Library had errors " + url);
            }
            this._library.resolve(resourceManager);
            for each(_loc1_ in this._library.resourceGroup.resources)
            {
               addChild(_loc1_.url,AnimClipResource);
            }
         }
      }
      
      public function get library() : AnimLibrary
      {
         return this._library;
      }
      
      override protected function internalUnload() : void
      {
         if(this._library)
         {
            this.library.cleanup();
            this._library = null;
         }
      }
      
      override public function get canUnloadResource() : Boolean
      {
         return true;
      }
   }
}
