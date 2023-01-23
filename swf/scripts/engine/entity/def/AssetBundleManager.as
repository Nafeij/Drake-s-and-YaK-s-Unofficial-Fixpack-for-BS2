package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.resource.IResource;
   import engine.resource.IResourceGroup;
   import engine.resource.IResourceManager;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class AssetBundleManager implements IAssetBundleManager
   {
       
      
      public var _resman:IResourceManager;
      
      public var byId:Dictionary;
      
      public var _id:String;
      
      public var _logger:ILogger;
      
      public function AssetBundleManager(param1:String, param2:IResourceManager)
      {
         this.byId = new Dictionary();
         super();
         this._resman = param2;
         this._id = param1;
         this._logger = param2.logger;
      }
      
      public function toString() : String
      {
         return this._id;
      }
      
      public function addExtraResource(param1:String, param2:Class, param3:IResourceGroup) : IResource
      {
         return this._resman.getResource(param1,param2,param3);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get resman() : IResourceManager
      {
         return this._resman;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function cleanup() : void
      {
         var _loc1_:IResourceAssetBundle = null;
         for each(_loc1_ in this.byId)
         {
            if(!_loc1_.isReleased)
            {
               this.logger.error("Failed to release " + _loc1_);
            }
         }
         this.byId = null;
         this._logger = null;
         this._resman = null;
      }
      
      protected function findExistingBundle(param1:String, param2:IAssetBundle) : IResourceAssetBundle
      {
         var _loc3_:IResourceAssetBundle = this.byId[param1];
         if(_loc3_)
         {
            if(!_loc3_.isReleased)
            {
               if(param2)
               {
                  param2.addBundle(_loc3_);
               }
               return _loc3_;
            }
            delete this.byId[param1];
            _loc3_ = null;
         }
         return null;
      }
      
      public function registerBundle(param1:IResourceAssetBundle) : void
      {
         if(this.findExistingBundle(param1.id,null))
         {
            throw new IllegalOperationError("registering pre-existing bundle? " + param1);
         }
         this.byId[param1.id] = param1;
      }
      
      public function getDebugListing() : String
      {
         var _loc2_:IAssetBundle = null;
         var _loc3_:* = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.byId)
         {
            _loc1_++;
         }
         _loc3_ = this.toString() + " count: " + _loc1_ + "\n";
         for each(_loc2_ in this.byId)
         {
            _loc3_ += _loc2_.getDebugSummaryLine() + "\n";
         }
         return _loc3_;
      }
      
      public function getDebugInfo(param1:String) : String
      {
         var _loc2_:IAssetBundle = this.byId[param1];
         return _loc2_.getDebugInfo();
      }
      
      public function purge() : void
      {
         var _loc1_:Vector.<IAssetBundle> = null;
         var _loc2_:IAssetBundle = null;
         for each(_loc2_ in this.byId)
         {
            if(_loc2_.isReleased)
            {
               if(!_loc1_)
               {
                  _loc1_ = new Vector.<IAssetBundle>();
               }
               _loc1_.push(_loc2_);
            }
         }
         if(!_loc1_)
         {
            return;
         }
         for each(_loc2_ in _loc1_)
         {
            this.logger.i("BNDL","purging " + _loc2_);
            delete this.byId[_loc2_.id];
            _loc2_.cleanup();
         }
      }
   }
}
