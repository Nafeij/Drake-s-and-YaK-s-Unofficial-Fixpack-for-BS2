package engine.saga
{
   import engine.resource.IResourceManager;
   import flash.utils.Dictionary;
   
   public class SagaAssetBundles
   {
       
      
      public var bundles:Dictionary;
      
      public var _last_id:int = 0;
      
      public var saga:ISaga;
      
      public var resman:IResourceManager;
      
      public function SagaAssetBundles(param1:ISaga, param2:IResourceManager)
      {
         this.bundles = new Dictionary();
         super();
         this.saga = param1;
         this.resman = param2;
      }
      
      public function cleanup() : void
      {
         var _loc1_:SagaAssetBundle = null;
         for each(_loc1_ in SagaAssetBundles)
         {
            _loc1_.cleanup();
         }
         this.bundles = null;
      }
      
      public function createSagaAssetBundle(param1:String) : SagaAssetBundle
      {
         if(!param1)
         {
            param1 = "_sab_" + ++this._last_id;
         }
         if(this.bundles[param1])
         {
            throw new ArgumentError("already have bundle [" + param1 + "]");
         }
         var _loc2_:SagaAssetBundle = new SagaAssetBundle(param1,this.saga,this.resman);
         this.bundles[param1] = _loc2_;
         return _loc2_;
      }
      
      public function removeSagaAssetBundle(param1:String) : void
      {
         var _loc2_:SagaAssetBundle = this.bundles[param1];
         delete this.bundles[param1];
         _loc2_.cleanup();
      }
      
      public function getSagaAssetBundle(param1:String) : SagaAssetBundle
      {
         return this.bundles[param1];
      }
   }
}
