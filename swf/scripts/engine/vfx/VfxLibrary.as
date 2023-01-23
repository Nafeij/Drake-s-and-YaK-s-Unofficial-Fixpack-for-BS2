package engine.vfx
{
   import engine.anim.def.IAnimFacing;
   import engine.core.locale.LocaleId;
   import engine.core.logging.ILogger;
   import engine.resource.AnimClipResource;
   import engine.resource.IResourceManager;
   import engine.resource.ResourceGroup;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class VfxLibrary
   {
       
      
      protected var vfxDefsByName:Dictionary;
      
      protected var _vfxDefs:Vector.<VfxDef>;
      
      protected var orientedVfxDefsByName:Dictionary;
      
      protected var _orientedVfxDefs:Vector.<OrientedVfxDef>;
      
      protected var logger:ILogger;
      
      private var resourceGroup:ResourceGroup;
      
      public var inheritUrls:Vector.<String>;
      
      public var inherits:Vector.<VfxLibrary>;
      
      public var url:String;
      
      public function VfxLibrary(param1:String, param2:ILogger)
      {
         this.vfxDefsByName = new Dictionary();
         this._vfxDefs = new Vector.<VfxDef>();
         this.orientedVfxDefsByName = new Dictionary();
         this._orientedVfxDefs = new Vector.<OrientedVfxDef>();
         this.inheritUrls = new Vector.<String>();
         this.inherits = new Vector.<VfxLibrary>();
         super();
         this.url = param1;
         this.logger = param2;
         this.resourceGroup = new ResourceGroup(this,param2);
      }
      
      public function toString() : String
      {
         return this.url;
      }
      
      public function resolve(param1:IResourceManager) : void
      {
         var _loc2_:VfxLibrary = null;
         var _loc3_:LocaleId = null;
         var _loc4_:VfxDef = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         for each(_loc2_ in this.inherits)
         {
            _loc2_.resolve(param1);
         }
         _loc3_ = param1.getLocaleId();
         for each(_loc4_ in this._vfxDefs)
         {
            _loc4_.resolveLocalization(_loc3_);
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numClipUrls)
            {
               _loc6_ = _loc4_.getClipUrl(_loc5_);
               param1.getResource(_loc6_,AnimClipResource,this.resourceGroup);
               _loc5_++;
            }
         }
         this.resourceGroup.addResourceGroupListener(this.resourceGroupCompleteHandler);
      }
      
      public function cleanup() : void
      {
         this.resourceGroup.release();
         this.resourceGroup = null;
      }
      
      public function getVfxDef(param1:String) : VfxDef
      {
         var _loc3_:VfxLibrary = null;
         var _loc2_:VfxDef = this.vfxDefsByName[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc3_ in this.inherits)
         {
            _loc2_ = _loc3_.getVfxDef(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getOrientedVfxDef(param1:String) : OrientedVfxDef
      {
         var _loc3_:VfxLibrary = null;
         var _loc2_:OrientedVfxDef = this.orientedVfxDefsByName[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc3_ in this.inherits)
         {
            _loc2_ = _loc3_.getOrientedVfxDef(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addVfxDef(param1:VfxDef) : void
      {
         this._vfxDefs.push(param1);
         this.vfxDefsByName[param1.name] = param1;
      }
      
      public function getVfxDefByFacing(param1:String, param2:IAnimFacing) : VfxDef
      {
         var _loc4_:String = null;
         var _loc3_:OrientedVfxDef = this.getOrientedVfxDef(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.getVfx(param2);
            return this.getVfxDef(_loc4_);
         }
         return null;
      }
      
      protected function addOrientedVfxDef(param1:OrientedVfxDef) : void
      {
         this._orientedVfxDefs.push(param1);
         this.orientedVfxDefsByName[param1.name] = param1;
      }
      
      public function get vfxDefs() : Vector.<VfxDef>
      {
         return this._vfxDefs;
      }
      
      public function get orientedVfxDefs() : Vector.<OrientedVfxDef>
      {
         return this._orientedVfxDefs;
      }
      
      private function resourceGroupCompleteHandler(param1:Event) : void
      {
         var _loc2_:VfxDef = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:AnimClipResource = null;
         for each(_loc2_ in this._vfxDefs)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numClipUrls)
            {
               _loc4_ = _loc2_.getClipUrl(_loc3_);
               _loc5_ = this.resourceGroup.getResource(_loc4_) as AnimClipResource;
               if(!_loc5_)
               {
                  this.resourceGroup.getResource(_loc4_) as AnimClipResource;
                  throw new IllegalOperationError("AnimClipResource [" + _loc4_ + "] was not found in resource group for [ " + this + "]");
               }
               if(_loc5_.ok)
               {
                  _loc2_.setClip(_loc3_,_loc5_.clipDef);
               }
               else
               {
                  _loc2_.setClip(_loc3_,null);
                  _loc2_.error = true;
               }
               _loc3_++;
            }
         }
      }
      
      public function getAnimClipResource(param1:String) : AnimClipResource
      {
         var _loc3_:VfxLibrary = null;
         var _loc2_:AnimClipResource = this.resourceGroup.getResource(param1) as AnimClipResource;
         if(_loc2_)
         {
            return _loc2_;
         }
         for each(_loc3_ in this.inherits)
         {
            _loc2_ = _loc3_.getAnimClipResource(param1);
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function get groupResources() : Dictionary
      {
         return this.resourceGroup.resources;
      }
   }
}
