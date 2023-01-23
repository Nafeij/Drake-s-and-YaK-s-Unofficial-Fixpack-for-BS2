package engine.resource
{
   import engine.core.util.ObjectPool;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BitmapPool extends EventDispatcher
   {
       
      
      private var bmprs:Dictionary;
      
      private var pools:Dictionary;
      
      private var resman:IResourceManager;
      
      private var poolBmprs:Dictionary;
      
      private var defaultInitial:int;
      
      private var defaultLimit:int;
      
      private var popped:Dictionary;
      
      public function BitmapPool(param1:IResourceManager, param2:int, param3:int)
      {
         this.bmprs = new Dictionary();
         this.pools = new Dictionary();
         this.poolBmprs = new Dictionary();
         this.popped = new Dictionary();
         super();
         this.resman = param1;
         this.defaultInitial = param2;
         this.defaultLimit = param3;
      }
      
      public function cleanup() : void
      {
         var _loc1_:BitmapResource = null;
         for each(_loc1_ in this.bmprs)
         {
            _loc1_.removeEventListener(Event.COMPLETE,this.bmprCompleteHandler);
            _loc1_.refcount.releaseReference();
         }
         this.bmprs = null;
         this.pools = null;
         this.poolBmprs = null;
         this.popped = null;
         this.resman = null;
      }
      
      public function incrementPool(param1:String, param2:int) : ObjectPool
      {
         if(!this.pools)
         {
            return null;
         }
         var _loc3_:ObjectPool = this.pools[param1];
         if(_loc3_)
         {
            _loc3_.limit += param2;
            return _loc3_;
         }
         return this.addPool(param1,param2,param2);
      }
      
      public function addPool(param1:String, param2:int, param3:int) : ObjectPool
      {
         var _loc4_:ObjectPool = null;
         var _loc5_:BitmapResource = null;
         if(!this.pools)
         {
            return null;
         }
         if(param1)
         {
            if(param1.indexOf(".png") != param1.length - 4)
            {
               throw new ArgumentError("That\'s not a bitmap: " + param1);
            }
            _loc4_ = this.pools[param1];
            if(_loc4_)
            {
               _loc4_.limit = Math.max(_loc4_.limit,param3);
               return _loc4_;
            }
            _loc5_ = this.resman.getResource(param1,BitmapResource) as BitmapResource;
            this.bmprs[param1] = _loc5_;
            _loc4_ = new ObjectPool(param1,null,this.createBitmap,null,param2,param3);
            this.pools[param1] = _loc4_;
            this.poolBmprs[_loc4_] = _loc5_;
            _loc5_.addEventListener(Event.COMPLETE,this.bmprCompleteHandler);
            return _loc4_;
         }
         return null;
      }
      
      protected function bmprCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:ObjectPool = this.pools[param1.resource.url];
         if(_loc2_)
         {
            _loc2_.checkInitials();
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function createBitmap(param1:ObjectPool) : DisplayObjectWrapper
      {
         var _loc2_:BitmapResource = this.poolBmprs[param1];
         if(Boolean(_loc2_) && _loc2_.ok)
         {
            return _loc2_.getWrapper();
         }
         return null;
      }
      
      public function pop(param1:String) : DisplayObjectWrapper
      {
         var _loc3_:BitmapResource = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc2_:ObjectPool = this.addPool(param1,this.defaultInitial,this.defaultLimit);
         if(_loc2_)
         {
            _loc3_ = this.poolBmprs[_loc2_];
            _loc4_ = _loc2_.pop();
            if(_loc4_)
            {
               _loc4_.scaleX = _loc3_.scaleX;
               _loc4_.scaleY = _loc3_.scaleY;
               this.popped[_loc4_] = _loc2_;
               return _loc4_;
            }
         }
         return null;
      }
      
      public function reclaim(param1:DisplayObjectWrapper) : void
      {
         if(!this.popped)
         {
            return;
         }
         var _loc2_:ObjectPool = this.popped[param1];
         if(_loc2_)
         {
            delete this.popped[param1];
            _loc2_.reclaim(param1);
         }
      }
   }
}
