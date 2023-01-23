package lib.fmodstudio
{
   import engine.core.logging.ILogger;
   import engine.fmod.FmodManifest;
   import engine.fmod.FmodProjectInfo;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.def.DefResource;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundPreloader;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import lib.engine.sound.fmod.FmodSoundResource;
   import lib.engine.sound.fmod.IFmodSoundDriver;
   
   public class FmodFsbPreloader implements ISoundPreloader
   {
       
      
      private var group:ResourceGroup;
      
      private var urls:Vector.<String>;
      
      private var projInfos:Vector.<FmodProjectInfo>;
      
      private var _preloadUrl:String;
      
      private var _preloadInfo:DefResource;
      
      private var resman:ResourceManager;
      
      private var manifestResources:Dictionary;
      
      private var callback:Function;
      
      private var soundDriver:ISoundDriver;
      
      private var logger:ILogger;
      
      public function FmodFsbPreloader(param1:ResourceManager, param2:ISoundDriver)
      {
         this.urls = new Vector.<String>();
         this.projInfos = new Vector.<FmodProjectInfo>();
         this.manifestResources = new Dictionary();
         super();
         this.resman = param1;
         this.soundDriver = param2;
         this.logger = param1.logger;
         this.group = new ResourceGroup(this,param1.logger);
         this.group.addEventListener(Event.COMPLETE,this.resourceGroupCompleteHandler);
      }
      
      private function resourceGroupCompleteHandler(param1:Event) : void
      {
         var _loc2_:* = null;
         var _loc3_:DefResource = null;
         var _loc4_:FmodStudioSoundDriver = null;
         var _loc5_:* = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:FmodFsbResource = null;
         this.group.removeResourceGroupListener(this.resourceGroupCompleteHandler);
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("FmodFsbPreloader COMPLETE");
         }
         for(_loc2_ in this.manifestResources)
         {
            _loc3_ = this.manifestResources[_loc2_];
            if(_loc3_.ok)
            {
               this.soundDriver.fmodManfest.addManifest(new FmodManifest().fromJson(_loc3_.jo,this.logger));
            }
         }
         this.manifestResources = new Dictionary();
         if(Boolean(this._preloadInfo) && this._preloadInfo.ok)
         {
            _loc4_ = this.soundDriver as FmodStudioSoundDriver;
            if(!_loc4_)
            {
               this.logger.error("FmodFsbPreloader : Running the fmod fev preloader without an fmod sound driver");
            }
            for(_loc5_ in this._preloadInfo.jo)
            {
               for each(_loc6_ in this._preloadInfo.jo[_loc5_])
               {
                  if(this.logger.isDebugEnabled)
                  {
                     this.logger.debug("FmodFsbPreloader : Attempting to preload [" + _loc6_ + "] from sku [" + _loc5_ + "]");
                  }
                  _loc7_ = _loc4_.getResourcePath(_loc5_,_loc6_);
                  _loc8_ = this.resman.getResource(_loc7_,FmodFsbResource,this.group) as FmodFsbResource;
                  if(_loc8_)
                  {
                     _loc8_.bankName = _loc6_;
                     _loc8_.streaming = false;
                     _loc8_.soundDriver = this.soundDriver as IFmodSoundDriver;
                  }
                  else
                  {
                     this.logger.error("FmodFsbPreloader : Failed to getResource on bank [" + _loc7_ + "]");
                  }
               }
            }
            this._preloadInfo = null;
            this.group.addResourceGroupListener(this.preloadGroupCompleteHandler);
         }
         else
         {
            this.triggerCallback();
         }
      }
      
      private function preloadGroupCompleteHandler(param1:Event) : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("FmodFebPreloader Preloading banks COMPLETE");
         }
         this.triggerCallback();
      }
      
      private function triggerCallback() : void
      {
         var _loc1_:Function = this.callback;
         this.callback = null;
         if(_loc1_ != null)
         {
            _loc1_(this);
         }
      }
      
      public function addSound(param1:String) : void
      {
         this.urls.push(param1);
      }
      
      public function addProjectInfo(param1:FmodProjectInfo) : void
      {
         this.projInfos.push(param1);
      }
      
      public function setPreloadUrl(param1:String) : void
      {
         this._preloadUrl = param1;
      }
      
      public function load(param1:Function) : void
      {
         var _loc2_:FmodProjectInfo = null;
         var _loc3_:FmodSoundResource = null;
         this.callback = param1;
         for each(_loc2_ in this.projInfos)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("FmodFsbPreloader.load() - Loading [" + _loc2_.masterBankStringsUrl + "] [" + _loc2_.masterBankUrl + "] [" + _loc2_.manifestUrl + "]");
            }
            _loc3_ = this.resman.getResource(_loc2_.masterBankStringsUrl,FmodSoundResource,this.group) as FmodSoundResource;
            if(_loc3_)
            {
               _loc3_.soundDriver = this.soundDriver;
            }
            _loc3_ = this.resman.getResource(_loc2_.masterBankUrl,FmodSoundResource,this.group) as FmodSoundResource;
            if(_loc3_)
            {
               _loc3_.soundDriver = this.soundDriver;
            }
            this.manifestResources[_loc2_.manifestUrl] = this.resman.getResource(_loc2_.manifestUrl,DefResource,this.group) as DefResource;
         }
         if(this._preloadUrl)
         {
            this._preloadInfo = this.resman.getResource(this._preloadUrl,DefResource,this.group) as DefResource;
         }
         this.group.addResourceGroupListener(this.resourceGroupCompleteHandler);
      }
      
      public function get complete() : Boolean
      {
         return this.group.complete;
      }
   }
}
