package engine.resource
{
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.core.util.ObjectPool;
   import engine.core.util.StringUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class AnimClipSpritePool extends EventDispatcher
   {
       
      
      private var acrs:Dictionary;
      
      private var pools:Dictionary;
      
      public var resman:IResourceManager;
      
      private var poolAcrs:Dictionary;
      
      private var defaultInitial:int;
      
      private var defaultLimit:int;
      
      private var popped:Dictionary;
      
      public var autostart:Boolean = true;
      
      public var randomStart:Boolean = false;
      
      public var autoDriving:Boolean = true;
      
      public var smoothing:Boolean = true;
      
      public var waiting:int = 0;
      
      public function AnimClipSpritePool(param1:IResourceManager, param2:int, param3:int, param4:Boolean = true)
      {
         this.acrs = new Dictionary();
         this.pools = new Dictionary();
         this.poolAcrs = new Dictionary();
         this.popped = new Dictionary();
         super();
         this.resman = param1;
         this.defaultInitial = param2;
         this.defaultLimit = param3;
         this.smoothing = param4;
      }
      
      public function cleanup() : void
      {
         var _loc1_:AnimClipResource = null;
         var _loc2_:Array = null;
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc5_:ObjectPool = null;
         for each(_loc1_ in this.acrs)
         {
            _loc1_.removeResourceListener(this.animCliprCompleteHandler);
            _loc1_.release();
         }
         _loc2_ = [];
         for(_loc3_ in this.popped)
         {
            _loc2_.push(_loc3_);
         }
         for each(_loc4_ in _loc2_)
         {
            this.reclaim(_loc4_);
         }
         for each(_loc5_ in this.pools)
         {
            _loc5_.cleanup();
         }
         this.acrs = null;
         this.pools = null;
         this.poolAcrs = null;
         this.popped = null;
         this.resman = null;
      }
      
      public function addPool(param1:String, param2:int, param3:int) : ObjectPool
      {
         var _loc4_:String = null;
         var _loc5_:ObjectPool = null;
         var _loc6_:AnimClipResource = null;
         if(!this.pools)
         {
            return null;
         }
         if(param1)
         {
            _loc4_ = StringUtil.getDotSuffix(param1);
            if(_loc4_ != "clip" && _loc4_ != "clipq")
            {
               throw new ArgumentError("That\'s not a clip: " + param1);
            }
            _loc5_ = this.pools[param1];
            if(_loc5_)
            {
               _loc5_.limit = Math.max(_loc5_.limit,param3);
               return _loc5_;
            }
            _loc6_ = this.resman.getResource(param1,AnimClipResource) as AnimClipResource;
            this.acrs[param1] = _loc6_;
            _loc5_ = new ObjectPool(param1,null,this.createAnimClipSprite,null,param2,param3);
            this.pools[param1] = _loc5_;
            this.poolAcrs[_loc5_] = _loc6_;
            ++this.waiting;
            _loc6_.addResourceListener(this.animCliprCompleteHandler);
            return _loc5_;
         }
         return null;
      }
      
      protected function animCliprCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         param1.resource.removeResourceListener(this.animCliprCompleteHandler);
         --this.waiting;
         var _loc2_:ObjectPool = this.pools[param1.resource.url];
         if(_loc2_)
         {
            _loc2_.checkInitials();
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function createAnimClipSprite(param1:ObjectPool) : DisplayObjectWrapper
      {
         var _loc3_:XAnimClipSpriteBase = null;
         var _loc2_:AnimClipResource = this.poolAcrs[param1];
         if(_loc2_)
         {
            if(!_loc2_.ok)
            {
               this.resman.logger.error("AnimClipSpritePool attempt to create before loaded: " + _loc2_.url);
               return null;
            }
            _loc3_ = _loc2_.animClipSprite;
            _loc3_.smoothing = this.smoothing;
            if(this.autostart)
            {
               if(Boolean(_loc3_.clip) && Boolean(_loc3_.clip.def))
               {
                  if(this.randomStart)
                  {
                     _loc3_.clip.start(_loc3_.clip.def.numFrames * Math.random());
                  }
                  else
                  {
                     _loc3_.clip.start(0);
                  }
               }
            }
            return _loc3_.displayObjectWrapper;
         }
         return null;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:* = null;
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:XAnimClipSpriteBase = null;
         if(this.autoDriving)
         {
            for(_loc2_ in this.popped)
            {
               _loc3_ = _loc2_ as DisplayObjectWrapper;
               _loc4_ = _loc3_.anim;
               if(Boolean(_loc4_) && Boolean(_loc4_.clip))
               {
                  _loc4_._clip.advance(param1);
                  _loc4_.update();
               }
            }
         }
      }
      
      public function pop(param1:String) : DisplayObjectWrapper
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:XAnimClipSpriteBase = null;
         var _loc2_:ObjectPool = this.addPool(param1,this.defaultInitial,this.defaultLimit);
         if(_loc2_)
         {
            _loc3_ = _loc2_.pop();
            if(_loc3_)
            {
               _loc4_ = _loc3_.anim;
               if(Boolean(_loc4_) && Boolean(_loc4_.clip))
               {
                  _loc4_.clip.repeatLimit = 0;
               }
               this.popped[_loc3_] = _loc2_;
               return _loc3_;
            }
         }
         return null;
      }
      
      public function reclaim(param1:DisplayObjectWrapper) : void
      {
         var _loc2_:ObjectPool = this.popped[param1];
         if(_loc2_)
         {
            delete this.popped[param1];
            _loc2_.reclaim(param1);
         }
      }
   }
}
