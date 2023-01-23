package engine.entity.def
{
   import engine.resource.IResource;
   import engine.resource.IResourceGroup;
   import engine.resource.IResourceManager;
   import engine.resource.ResourceGroup;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class ResourceAssetBundle extends AssetBundle implements IResourceAssetBundle
   {
       
      
      protected var _group:IResourceGroup;
      
      protected var _resman:IResourceManager;
      
      protected var _preloads:IAssetBundleManager;
      
      public function ResourceAssetBundle(param1:String, param2:IAssetBundleManager)
      {
         super(param1,param2.logger);
         this._resman = param2.resman;
         this._preloads = param2;
         this._group = new ResourceGroup(this,logger);
         param2.registerBundle(this);
      }
      
      override public function toString() : String
      {
         return "RESOURCE " + _id;
      }
      
      public function listenForCompletion() : void
      {
         this._group.addResourceGroupListener(this.groupCompleteHandler);
      }
      
      protected function handleGroupComplete() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      private function groupCompleteHandler(param1:Event) : void
      {
         this.handleGroupComplete();
         if(this._group.complete)
         {
            this._group.removeResourceGroupListener(this.groupCompleteHandler);
            if(!refcount)
            {
               this._handleUnload();
            }
         }
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function _handleUnload() : void
      {
         super._handleUnload();
         this._group.releaseReference();
         this._resman = null;
      }
      
      public function get group() : IResourceGroup
      {
         return this._group;
      }
      
      public function get preloads() : IAssetBundleManager
      {
         return this._preloads;
      }
      
      public function get resman() : IResourceManager
      {
         return this._resman;
      }
      
      public function addExtraResource(param1:String, param2:Class) : IResource
      {
         return this._resman.getResource(param1,param2,this._group);
      }
      
      override public function getDebugInfo() : String
      {
         var _loc1_:String = super.getDebugInfo();
         if(this._group)
         {
            _loc1_ += "\nGroup: " + this._group.getDebugInfo();
         }
         return _loc1_;
      }
   }
}
