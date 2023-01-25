package engine.entity.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Refcount;
   import engine.core.util.StringUtil;
   import flash.errors.IllegalOperationError;
   
   public class AssetBundle implements IAssetBundle
   {
       
      
      private var _bundles:Vector.<IAssetBundle>;
      
      protected var _logger:ILogger;
      
      protected var _id:String;
      
      private var _isReleased:Boolean;
      
      private var _refcount:Refcount;
      
      private var _isAutodiscard:Boolean;
      
      public function AssetBundle(param1:String, param2:ILogger)
      {
         this._refcount = new Refcount(this);
         super();
         this._logger = param2;
         this._id = param1;
      }
      
      public function cleanup() : void
      {
         var _loc1_:IAssetBundle = null;
         for each(_loc1_ in this._bundles)
         {
            if(!_loc1_.isReleased)
            {
               this.logger.error("unreleased asset bundle " + _loc1_);
            }
         }
         this._bundles = null;
         this._refcount = null;
      }
      
      public function toString() : String
      {
         return "BUNDLE=" + this._id;
      }
      
      protected function _handleUnload() : void
      {
         var _loc1_:IAssetBundle = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.d("BNDL","unloading " + this);
         }
         if(this._isReleased)
         {
            throw new IllegalOperationError("double unload");
         }
         this._isReleased = true;
         if(this._bundles)
         {
            for each(_loc1_ in this._bundles)
            {
               _loc1_.releaseReference();
            }
         }
         this._bundles = null;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get bundles() : Vector.<IAssetBundle>
      {
         return this._bundles;
      }
      
      public function addBundle(param1:IAssetBundle) : void
      {
         if(!this._bundles)
         {
            this._bundles = new Vector.<IAssetBundle>();
         }
         this._bundles.push(param1);
         param1.addReference();
      }
      
      public function releaseReference() : void
      {
         if(this._refcount.refcount == 0)
         {
            if(!this.isReleased)
            {
               this._handleUnload();
               return;
            }
            throw new IllegalOperationError("releasing a reference with zero refcount " + this);
         }
         this._refcount.releaseReference();
         if(this._refcount.refcount == 0)
         {
            this._handleUnload();
         }
      }
      
      public function addReference() : void
      {
         this._refcount.addReference();
      }
      
      public function get refcount() : uint
      {
         return this._refcount.refcount;
      }
      
      public function get isReleased() : Boolean
      {
         return this._isReleased;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get numBundles() : int
      {
         return !!this._bundles ? int(this._bundles.length) : 0;
      }
      
      public function getDebugSummaryLine() : String
      {
         var _loc1_:String = "";
         _loc1_ += StringUtil.padRight(this._id," ",40) + " ";
         _loc1_ += "refs: " + StringUtil.padLeft(this.refcount.toString()," ",3) + " ";
         _loc1_ += "bdls: " + StringUtil.padLeft(this.numBundles.toString()," ",3) + " ";
         return _loc1_ + (this._isReleased ? "RELEASED " : "         ");
      }
      
      public function getDebugInfo() : String
      {
         var _loc2_:IAssetBundle = null;
         var _loc1_:* = "";
         _loc1_ += this.getDebugSummaryLine();
         if(this._bundles)
         {
            _loc1_ += "\nBundles:\n";
            for each(_loc2_ in this._bundles)
            {
               _loc1_ += _loc2_.getDebugSummaryLine() + "\n";
            }
         }
         return _loc1_;
      }
   }
}
