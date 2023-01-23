package engine.resource
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class ResourceTree
   {
       
      
      public var children:Vector.<ChildInfo>;
      
      public var byUrl:Dictionary;
      
      public var root:Resource;
      
      public var rootLoaded:Boolean;
      
      public function ResourceTree(param1:Resource)
      {
         this.children = new Vector.<ChildInfo>();
         this.byUrl = new Dictionary();
         super();
         if(null == param1)
         {
            throw new ArgumentError("null root");
         }
         this.root = param1;
      }
      
      protected function childResourceCompleteHandler(param1:Event) : void
      {
         this.checkChildren();
      }
      
      public function handleRootResourceLoadComplete() : void
      {
         var _loc1_:ChildInfo = null;
         if(this.rootLoaded)
         {
            throw new IllegalOperationError("Attempting to in-place reload the root of an ResourceTree.  This is currently not supported");
         }
         this.rootLoaded = true;
         for each(_loc1_ in this.children)
         {
            _loc1_.startLoad();
         }
         this.checkChildren();
      }
      
      public function checkChildren() : void
      {
         var _loc1_:ChildInfo = null;
         if(!this.rootLoaded)
         {
            return;
         }
         for each(_loc1_ in this.children)
         {
            if(!_loc1_.loaded)
            {
               return;
            }
         }
         this.root.setFinishing();
      }
      
      public function release() : void
      {
         var _loc1_:Vector.<ChildInfo> = null;
         var _loc2_:ChildInfo = null;
         if(this.children)
         {
            _loc1_ = this.children;
            _loc1_ = this.children;
            this.children = null;
            this.byUrl = null;
            for each(_loc2_ in _loc1_)
            {
               _loc2_.release();
            }
         }
      }
      
      internal function addChild(param1:String, param2:Class) : void
      {
         if(this.byUrl[param1])
         {
            return;
         }
         var _loc3_:ChildInfo = new ChildInfo(this,param1,param2);
         this.children.push(_loc3_);
         this.byUrl[param1] = _loc3_;
         if(this.rootLoaded)
         {
            _loc3_.startLoad();
            this.checkChildren();
         }
      }
      
      public function removeChild(param1:String) : void
      {
         var _loc3_:int = 0;
         if(!this.children)
         {
            return;
         }
         var _loc2_:ChildInfo = this.byUrl[param1];
         delete this.byUrl[param1];
         if(_loc2_)
         {
            _loc3_ = this.children.indexOf(_loc2_);
            if(_loc3_ >= 0)
            {
               this.children.splice(_loc3_,1);
               _loc2_.release();
            }
         }
      }
   }
}

import engine.resource.Resource;
import engine.resource.ResourceTree;
import engine.resource.loader.IResourceLoader;
import flash.errors.IllegalOperationError;
import flash.events.Event;

class ChildInfo
{
    
   
   public var clazz:Class;
   
   public var url:String;
   
   public var resource:Resource;
   
   public var tree:ResourceTree;
   
   public function ChildInfo(param1:ResourceTree, param2:String, param3:Class)
   {
      super();
      this.tree = param1;
      this.url = param2;
      this.clazz = param3;
   }
   
   public function startLoad() : void
   {
      if(this.resource)
      {
         throw new IllegalOperationError("double load");
      }
      this.resource = this.tree.root.resourceManager.getResource(this.url,this.clazz,null,null) as Resource;
      this.resource.addEventListener(Event.COMPLETE,this.childResourceCompleteHandler);
   }
   
   public function release() : void
   {
      if(this.resource)
      {
         this.resource.removeEventListener(Event.COMPLETE,this.childResourceCompleteHandler);
         this.resource.refcount.releaseReference();
         this.resource = null;
         this.tree = null;
      }
   }
   
   protected function childResourceCompleteHandler(param1:Event) : void
   {
      this.resource.removeEventListener(Event.COMPLETE,this.childResourceCompleteHandler);
      this.tree.checkChildren();
   }
   
   public function get loaded() : Boolean
   {
      return Boolean(this.resource) && (Boolean(this.resource.ok) || Boolean(this.resource.error));
   }
   
   public function get loading() : Boolean
   {
      return Boolean(this.resource) && !this.resource.ok && !this.resource.error;
   }
   
   public function get loader() : IResourceLoader
   {
      return !!this.resource ? this.resource.loader : null;
   }
}
