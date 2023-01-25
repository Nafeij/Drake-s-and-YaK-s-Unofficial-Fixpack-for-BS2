package game.gui
{
   import engine.core.logging.ILogger;
   import engine.resource.BitmapResource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   
   public class GuiBitmapHolderHelper
   {
      
      public static var ENABLED:Boolean = true;
       
      
      private var bmpholders:Dictionary;
      
      private var bmpholders_complete:Dictionary;
      
      private var num_waits:int;
      
      private var callbackComplete:Function;
      
      private var bmpholder_prefix:String = "bmpholder_";
      
      private var resman:ResourceManager;
      
      private var logger:ILogger;
      
      private var resourceGroup:ResourceGroup;
      
      public function GuiBitmapHolderHelper(param1:ResourceManager, param2:Function)
      {
         this.bmpholders = new Dictionary();
         this.bmpholders_complete = new Dictionary();
         super();
         this.resman = param1;
         this.logger = param1.logger;
         this.callbackComplete = param2;
      }
      
      public function get isComplete() : Boolean
      {
         return this.num_waits <= 0;
      }
      
      public function cleanup() : void
      {
         var _loc1_:Object = null;
         var _loc2_:BitmapResource = null;
         for(_loc1_ in this.bmpholders)
         {
            _loc2_ = _loc1_ as BitmapResource;
            _loc2_.removeResourceListener(this.bmpholderHandler);
         }
         this.bmpholders = null;
         if(this.resourceGroup)
         {
            this.resourceGroup.release();
            this.resourceGroup = null;
         }
      }
      
      private function bmpholderHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:BitmapResource = null;
         var _loc4_:MovieClip = null;
         var _loc5_:Bitmap = null;
         var _loc6_:int = 0;
         _loc2_ = param1.resource as BitmapResource;
         _loc2_.removeResourceListener(this.bmpholderHandler);
         var _loc3_:Vector.<MovieClip> = this.bmpholders[_loc2_];
         if(!this.bmpholders_complete[_loc2_])
         {
            --this.num_waits;
         }
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_)
            {
               _loc5_ = _loc2_.bmp;
               if(!_loc5_)
               {
                  this.logger.error("Failed to load bitmap for bmpholderHandler " + _loc2_.url + " for " + _loc4_.name);
               }
               else if(_loc4_.parent)
               {
                  _loc6_ = _loc4_.parent.getChildIndex(_loc4_);
                  _loc5_.name = _loc4_.name.replace("bmpholder","");
                  _loc4_.parent.addChildAt(_loc5_,_loc6_);
                  _loc5_.visible = true;
                  _loc5_.x = _loc4_.x;
                  _loc5_.y = _loc4_.y;
                  _loc5_.scaleX = _loc4_.scaleX * _loc2_.scaleX;
                  _loc5_.scaleY = _loc4_.scaleY * _loc2_.scaleY;
               }
               else
               {
                  this.logger.error("No bitmap holder parent");
               }
            }
         }
         this.checkComplete();
      }
      
      private function checkComplete() : void
      {
         var _loc1_:Function = null;
         if(this.num_waits == 0)
         {
            _loc1_ = this.callbackComplete;
            if(_loc1_ != null)
            {
               this.callbackComplete = null;
               _loc1_(this);
            }
         }
      }
      
      public function loadGuiBitmaps(param1:DisplayObject, param2:Dictionary = null) : void
      {
         var _loc3_:MovieClip = null;
         var _loc5_:Vector.<DisplayObjectContainer> = null;
         var _loc6_:DisplayObjectContainer = null;
         var _loc7_:* = null;
         var _loc8_:BitmapResource = null;
         var _loc9_:Vector.<MovieClip> = null;
         var _loc10_:int = 0;
         if(!ENABLED)
         {
            this.checkComplete();
            return;
         }
         _loc3_ = param1 as MovieClip;
         if(Boolean(_loc3_) && _loc3_.name.indexOf(this.bmpholder_prefix) == 0)
         {
            if(!_loc3_.visible)
            {
               this.logger.info("GuiBitmapHolderHelper skipping invisible " + _loc3_ + "/" + _loc3_.name);
               return;
            }
            if(!this.resourceGroup)
            {
               this.resourceGroup = new ResourceGroup(this,this.logger);
            }
            if(_loc3_.numChildren)
            {
               this.logger.error("GuiBitmapHolderHelper " + _loc3_.name + ":  A holder with a ghost-childer?  What the **** happened?!");
            }
            _loc7_ = _loc3_.name.substr(this.bmpholder_prefix.length);
            if(Boolean(param2) && Boolean(param2[_loc7_]))
            {
               this.logger.info("GuiBitmapHolderHelper skipping IGNORED " + _loc3_ + "/" + _loc3_.name);
               return;
            }
            if(_loc7_.indexOf("pages__pg_backdrop") >= 0)
            {
               _loc7_ = _loc7_;
            }
            _loc7_ = _loc7_.replace(/__/g,"/");
            _loc7_ += ".png";
            _loc8_ = this.resman.getResource(_loc7_,BitmapResource,this.resourceGroup) as BitmapResource;
            _loc3_.mouseEnabled = _loc3_.mouseChildren = false;
            _loc3_.visible = false;
            _loc9_ = this.bmpholders[_loc8_];
            if(!_loc9_)
            {
               ++this.num_waits;
               _loc9_ = new Vector.<MovieClip>();
               this.bmpholders[_loc8_] = _loc9_;
            }
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("GuiBitmapHolderHelper loading for " + _loc3_ + ": " + _loc7_);
            }
            _loc9_.push(_loc3_);
            _loc8_.addResourceListener(this.bmpholderHandler);
         }
         var _loc4_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc4_)
         {
            _loc10_ = 0;
            while(_loc10_ < _loc4_.numChildren)
            {
               _loc6_ = _loc4_.getChildAt(_loc10_) as DisplayObjectContainer;
               if(_loc6_)
               {
                  if(!_loc5_)
                  {
                     _loc5_ = new Vector.<DisplayObjectContainer>();
                  }
                  _loc5_.push(_loc6_);
               }
               _loc10_++;
            }
         }
         if(_loc5_)
         {
            for each(_loc6_ in _loc5_)
            {
               this.loadGuiBitmaps(_loc6_,param2);
            }
         }
         this.checkComplete();
      }
   }
}
