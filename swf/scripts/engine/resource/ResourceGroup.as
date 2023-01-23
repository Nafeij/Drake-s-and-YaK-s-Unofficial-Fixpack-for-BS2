package engine.resource
{
   import engine.core.logging.ILogger;
   import engine.core.util.Refcount;
   import engine.resource.event.ResourceLoadedEvent;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ResourceGroup extends EventDispatcher implements IResourceGroup
   {
       
      
      public var resources:Dictionary;
      
      private var waitingResources:Dictionary;
      
      private var waitingCount:int;
      
      private var logger:ILogger;
      
      private var owner:Object;
      
      public var immediatelyRelease:Boolean;
      
      private var _originalUrlToResources:Dictionary;
      
      private var urlMappings:Dictionary;
      
      private var _urlUnmappings:Dictionary;
      
      private var _refcount:Refcount;
      
      public function ResourceGroup(param1:Object, param2:ILogger)
      {
         this.resources = new Dictionary();
         this.waitingResources = new Dictionary();
         this._originalUrlToResources = new Dictionary();
         this._refcount = new Refcount(this);
         super();
         this.owner = param1;
         this.logger = param2;
         this.addReference();
      }
      
      public function get originalUrlToResources() : Dictionary
      {
         return this._originalUrlToResources;
      }
      
      public function get urlUnmappings() : Dictionary
      {
         return this._urlUnmappings;
      }
      
      public function getResource(param1:String) : Resource
      {
         var _loc2_:String = null;
         if(this.urlMappings)
         {
            _loc2_ = this.urlMappings[param1];
            if(_loc2_)
            {
               return this.resources[_loc2_];
            }
         }
         return this.resources[param1];
      }
      
      public function hasResource(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(this.urlMappings)
         {
            _loc2_ = this.urlMappings[param1];
            if(_loc2_)
            {
               return _loc2_ in this.resources;
            }
         }
         return param1 in this.resources;
      }
      
      private function noticeUrlMapping(param1:String, param2:String) : void
      {
         if(param1 == param2)
         {
            return;
         }
         if(!this.urlMappings)
         {
            this.urlMappings = new Dictionary();
         }
         if(!this._urlUnmappings)
         {
            this._urlUnmappings = new Dictionary();
         }
         this.urlMappings[param1] = param2;
         this._urlUnmappings[param2] = param1;
      }
      
      public function addResource(param1:IResource, param2:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(!(param1.url in this.resources))
         {
            this.resources[param1.url] = param1;
            this.waitingResources[param1] = param1;
            this.noticeUrlMapping(param2,param1.url);
            this._originalUrlToResources[param2] = param1;
            ++this.waitingCount;
            param1.addEventListener(Event.UNLOAD,this.resourceUnloadHandler);
            param1.addResourceListener(this.resourceCompleteHandler);
         }
      }
      
      public function releaseResource(param1:String) : void
      {
         var _loc2_:Resource = this.resources[param1];
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
            _loc2_.removeResourceListener(this.resourceCompleteHandler);
            if(this.waitingResources[_loc2_])
            {
               --this.waitingCount;
               delete this.waitingResources[_loc2_];
            }
            _loc2_.release();
            delete this.resources[param1];
         }
      }
      
      private function _handleUnload() : void
      {
         var _loc1_:Resource = null;
         for each(_loc1_ in this.resources)
         {
            _loc1_.removeResourceListener(this.resourceCompleteHandler);
            _loc1_.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
            _loc1_.refcount.releaseReference();
         }
         this.resources = new Dictionary();
         this.waitingResources = new Dictionary();
         this.waitingCount = 0;
      }
      
      private function resourceUnloadHandler(param1:Event) : void
      {
         var _loc2_:Resource = param1.target as Resource;
         _loc2_.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
         this.logger.error("ResourceGroup [" + this.owner + "] should never receive unload event, url=[" + _loc2_.url + "]");
      }
      
      private function resourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:IResource = param1.resource;
         _loc2_.removeResourceListener(this.resourceCompleteHandler);
         if(_loc2_ in this.waitingResources)
         {
            delete this.waitingResources[_loc2_];
            --this.waitingCount;
            if(this.immediatelyRelease)
            {
               _loc2_.removeEventListener(Event.UNLOAD,this.resourceUnloadHandler);
               delete this.resources[_loc2_.url];
               _loc2_.release();
            }
            this.checkComplete();
         }
      }
      
      private function checkComplete() : void
      {
         if(!this.waitingCount)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function removeResourceGroupListener(param1:Function) : void
      {
         removeEventListener(Event.COMPLETE,param1,false);
      }
      
      public function addResourceGroupListener(param1:Function) : void
      {
         addEventListener(Event.COMPLETE,param1,false,0,true);
         this.checkComplete();
      }
      
      public function get complete() : Boolean
      {
         return !this.waitingCount;
      }
      
      public function releaseReference() : void
      {
         if(this._refcount.refcount <= 0)
         {
            throw new IllegalOperationError("too many releases!");
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
         return !!this._refcount ? this._refcount.refcount : 0;
      }
      
      public function release() : void
      {
         this.releaseReference();
      }
      
      public function get isReleased() : Boolean
      {
         return !this._refcount || this._refcount.refcount == 0;
      }
      
      public function getDebugInfo() : String
      {
         var _loc2_:Resource = null;
         var _loc1_:* = "";
         _loc1_ += "refcount=" + this.refcount;
         _loc1_ += this.isReleased ? "RELEASED " : "         ";
         _loc1_ += "\n";
         _loc1_ += "Resources:\n";
         for each(_loc2_ in this.resources)
         {
            _loc1_ += "    " + _loc2_.url + "\n";
         }
         _loc1_ += "Waits (" + this.waitingCount + "):\n";
         for each(_loc2_ in this.waitingResources)
         {
            _loc1_ += "    " + _loc2_.url + "\n";
         }
         return _loc1_;
      }
   }
}
