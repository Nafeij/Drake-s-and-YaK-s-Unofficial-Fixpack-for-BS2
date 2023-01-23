package engine.resource
{
   import engine.anim.def.AnimClipDef;
   import engine.core.logging.ILogger;
   import engine.resource.def.DefResource;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.System;
   import flash.utils.getDefinitionByName;
   
   public class GlobalAssetPreloader extends EventDispatcher
   {
       
      
      protected var _group:ResourceGroup;
      
      protected var _resourceManager:IResourceManager;
      
      private var _assetList:DefResource;
      
      private var _assetListUrl:String;
      
      private var _logger:ILogger;
      
      public var ready:Boolean;
      
      private var _startingMemory:int;
      
      public function GlobalAssetPreloader(param1:String, param2:IResourceManager, param3:ILogger)
      {
         super();
         this._assetListUrl = param1;
         this._resourceManager = param2;
         this._group = new ResourceGroup(this,param3);
         this._logger = param3;
         this.ready = false;
      }
      
      public function load() : void
      {
         this._assetList = this._resourceManager.getResource(this._assetListUrl,DefResource,this._group) as DefResource;
         this._assetList.addEventListener(Event.COMPLETE,this.onLoadAssetFileComplete);
      }
      
      private function onLoadAssetFileComplete(param1:Event) : void
      {
         var assetClass:String = null;
         var clazzName:String = null;
         var clazz:Class = null;
         var assetClassArray:Array = null;
         var assetUrl:String = null;
         var event:Event = param1;
         if(Boolean(this._assetList) && this._assetList.ok)
         {
            this._startingMemory = System.privateMemory / (1024 * 1024);
            this._logger.info("Starting to preload assets -- Starting Memory [" + this._startingMemory + " MB]");
            for(assetClass in this._assetList.jo)
            {
               clazzName = assetClass;
               clazz = null;
               if(clazzName)
               {
                  try
                  {
                     clazz = getDefinitionByName(clazzName) as Class;
                  }
                  catch(e:Error)
                  {
                     _logger.error("Unable to find class [" + clazzName + "] for preloading assets from");
                     throw e;
                  }
               }
               if(!clazz)
               {
                  throw ArgumentError("No clazz found for [" + clazzName + "] when trying to load assets");
               }
               assetClassArray = this._assetList.jo[assetClass] as Array;
               if(!assetClassArray || !assetClassArray.length)
               {
                  throw ArgumentError("Class [" + assetClass + "] is not an array or does not have any members.");
               }
               for each(assetUrl in assetClassArray)
               {
                  if(!this._resourceManager.getResource(assetUrl,clazz,this._group))
                  {
                     this._logger.error("Failed to create the asset for " + assetUrl + "] of type [" + clazzName + "] while preloading assets");
                  }
               }
            }
            this._group.addResourceGroupListener(this.onResourceGroupLoadComplete);
         }
      }
      
      private function onResourceGroupLoadComplete(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Resource = null;
         var _loc5_:String = null;
         var _loc6_:AnimClipBagResource = null;
         var _loc7_:Number = NaN;
         var _loc8_:AnimClipDef = null;
         var _loc9_:Number = NaN;
         if(Boolean(this._group) && this._group.complete)
         {
            _loc2_ = System.privateMemory / (1024 * 1024);
            if(this._logger.isDebugEnabled)
            {
               _loc3_ = 0;
               for each(_loc4_ in this._group.resources)
               {
                  _loc5_ = _loc4_.url;
                  _loc6_ = _loc4_ as AnimClipBagResource;
                  if(Boolean(_loc6_) && Boolean(_loc6_.bag))
                  {
                     _loc7_ = 0;
                     this._logger.debug("Total Sizes for asset [" + _loc5_ + "]");
                     for each(_loc8_ in _loc6_.bag.clips)
                     {
                        _loc9_ = int(_loc8_.numBytes / (1024 * 1024) * 1000) / 1000;
                        _loc7_ += _loc9_;
                        this._logger.debug("\tClip [" + _loc8_._id + "] has size [" + _loc9_ + " MB]");
                     }
                     this._logger.debug("\tTotal Size is [" + int(_loc7_ * 1000) / 1000 + " MB]");
                     _loc3_ += _loc7_;
                  }
               }
               this._logger.info("Finished preloading assets -- Total Starting Memory [" + this._startingMemory + " MB] -- Total Ending Memory [" + _loc2_ + " MB] -- Total Estimated Preloaded Size [" + int(_loc3_ * 1000) / 1000 + " MB] -- Total Size Delta[" + (_loc2_ - this._startingMemory) + " MB]");
            }
            else
            {
               this._logger.info("Finished preloading assets -- Total Starting Memory [" + this._startingMemory + " MB] -- Total Ending Memory [" + _loc2_ + " MB] -- Total Size Delta [" + (_loc2_ - this._startingMemory) + " MB]");
            }
            this.ready = true;
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function cleanup() : void
      {
         this._startingMemory = 0;
         this._logger = null;
         this._assetList.release();
         this._assetList = null;
         this._group.release();
         this._group = null;
         this._resourceManager = null;
         this.ready = false;
      }
   }
}
