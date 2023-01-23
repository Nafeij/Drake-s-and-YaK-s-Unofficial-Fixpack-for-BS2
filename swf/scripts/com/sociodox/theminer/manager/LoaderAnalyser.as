package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.data.LoaderData;
   import com.sociodox.theminer.data.SWFEntry;
   import com.sociodox.theminer.window.Configuration;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLStream;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class LoaderAnalyser
   {
      
      private static var mInstance:LoaderAnalyser = null;
       
      
      private var mLoaderDict:Dictionary;
      
      private var mDisplayLoaderRef:Dictionary;
      
      private var mLoadersData:Array;
      
      public function LoaderAnalyser()
      {
         super();
         this.mLoadersData = new Array();
         this.mLoaderDict = new Dictionary(true);
         this.mDisplayLoaderRef = new Dictionary(true);
      }
      
      public static function GetInstance() : LoaderAnalyser
      {
         if(mInstance == null)
         {
            mInstance = new LoaderAnalyser();
         }
         return mInstance;
      }
      
      public function Update() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:LoaderInfo = null;
         var _loc3_:LoaderData = null;
         for(_loc1_ in this.mDisplayLoaderRef)
         {
            if(_loc1_ != null)
            {
               if(!(_loc1_ is SWFEntry))
               {
                  _loc2_ = _loc1_.contentLoaderInfo;
                  if(_loc2_ != null)
                  {
                     _loc3_ = this.mLoaderDict[_loc2_];
                     if(_loc3_ == null)
                     {
                     }
                  }
               }
            }
         }
      }
      
      public function GetLoadersData() : Array
      {
         return this.mLoadersData;
      }
      
      public function PushLoader(param1:*) : void
      {
         var _loc2_:LoaderData = null;
         var _loc3_:SWFEntry = null;
         var _loc4_:Loader = null;
         var _loc5_:URLStream = null;
         var _loc6_:URLLoader = null;
         if(param1 == null)
         {
            return;
         }
         if(param1 is SWFEntry)
         {
            _loc3_ = param1 as SWFEntry;
            if(param1 == null)
            {
               return;
            }
            _loc2_ = this.mLoaderDict[_loc3_];
            if(_loc2_ != null)
            {
               return;
            }
            this.mDisplayLoaderRef[param1] = true;
            _loc2_ = new LoaderData();
            _loc2_.mFirstEvent = getTimer();
            _loc2_.mLoadedBytes = _loc3_.mBytes.length;
            _loc2_.mLoadedBytesText = String(_loc2_.mLoadedBytes);
            _loc2_.mProgress = 1;
            _loc2_.mProgressText = Localization.Lbl_LD_SwfLoaded;
            if(_loc3_.mUrl != null)
            {
               _loc2_.mUrl = _loc3_.mUrl;
            }
            this.mLoadersData.push(_loc2_);
            this.mLoaderDict[_loc3_] = _loc2_;
            _loc2_.mType = LoaderData.SWF_LOADED;
            _loc2_.mLoadedData = _loc3_.mBytes;
         }
         else if(param1 is Loader)
         {
            _loc4_ = param1;
            if(_loc4_.contentLoaderInfo == null)
            {
               return;
            }
            _loc2_ = this.mLoaderDict[_loc4_.contentLoaderInfo];
            if(_loc2_ != null)
            {
               return;
            }
            this.mDisplayLoaderRef[param1] = true;
            _loc2_ = new LoaderData();
            if(_loc4_.contentLoaderInfo.url != null)
            {
               _loc2_.mUrl = _loc4_.contentLoaderInfo.url;
            }
            this.mLoadersData.push(_loc2_);
            this.mLoaderDict[_loc4_.contentLoaderInfo] = _loc2_;
            _loc2_.mType = LoaderData.DISPLAY_LOADER;
            this.configureListeners(_loc4_.contentLoaderInfo);
         }
         else if(param1 is URLStream)
         {
            _loc2_ = this.mLoaderDict[param1];
            if(_loc2_ != null)
            {
               return;
            }
            _loc5_ = param1;
            _loc2_ = new LoaderData();
            this.mLoaderDict[param1] = _loc2_;
            this.mLoadersData.push(_loc2_);
            _loc2_.mType = LoaderData.URL_STREAM;
            this.configureListeners(param1);
         }
         else if(param1 is URLLoader)
         {
            _loc2_ = this.mLoaderDict[param1];
            if(_loc2_ != null)
            {
               return;
            }
            _loc6_ = param1;
            _loc2_ = new LoaderData();
            this.mLoadersData.push(_loc2_);
            this.mLoaderDict[param1] = _loc2_;
            _loc2_.mType = LoaderData.URL_LOADER;
            this.configureListeners(param1);
         }
      }
      
      private function configureListeners(param1:IEventDispatcher) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = true;
         var _loc4_:int = int.MAX_VALUE;
         param1.addEventListener(Event.COMPLETE,this.completeHandler,_loc2_,_loc4_,_loc3_);
         param1.addEventListener(Event.OPEN,this.openHandler,_loc2_,_loc4_,_loc3_);
         param1.addEventListener(ProgressEvent.PROGRESS,this.progressHandler,_loc2_,_loc4_,_loc3_);
         param1.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.httpStatusHandler,_loc2_,_loc4_,_loc3_);
         param1.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler,_loc2_,_loc4_,_loc3_);
         if(param1 is Loader)
         {
            param1.addEventListener(Event.INIT,this.initHandler,_loc2_,_loc4_,_loc3_);
            param1.addEventListener(Event.UNLOAD,this.unLoadHandler,_loc2_,_loc4_,_loc3_);
         }
         else if(param1 is URLLoader)
         {
            param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler,_loc2_,_loc4_,_loc3_);
         }
         else if(param1 is URLStream)
         {
            param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityErrorHandler,_loc2_,_loc4_,_loc3_);
         }
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc4_:LoaderInfo = null;
         var _loc5_:ByteArray = null;
         var _loc2_:Boolean = Configuration.IsSamplingRequired();
         pauseSampling();
         var _loc3_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc3_ != null)
         {
            if(_loc3_.mFirstEvent == -1)
            {
               _loc3_.mFirstEvent = getTimer();
            }
            if(_loc3_.mIsFinished)
            {
               _loc3_ = this.PreventReUse(_loc3_,param1.target);
            }
            _loc3_.mProgress = 1;
            _loc3_.mProgressText = LoaderData.LOADER_STATUS_COMPLETED;
            _loc3_.mIsFinished = true;
            if(_loc3_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc4_ = param1.target as LoaderInfo;
               _loc5_ = new ByteArray();
               _loc4_.bytes.position = 0;
               _loc4_.bytes.readBytes(_loc5_,0,_loc4_.bytes.length);
               _loc3_.mLoadedData = null;
               _loc3_.mUrl = param1.target.url;
            }
            if(_loc3_.mUrl == null && _loc3_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc3_.mUrl = param1.target.url;
            }
            else if(param1.target is URLStream)
            {
               _loc3_.mUrl = Localization.Lbl_LA_NoUrlStream;
               _loc3_.mLoadedData = null;
            }
            if(param1.target is URLLoader)
            {
               _loc3_.mUrl = Localization.Lbl_LA_NoUrlLoader;
               _loc3_.mLoadedData = null;
            }
         }
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      private function PreventReUse(param1:LoaderData, param2:Object) : LoaderData
      {
         var _loc3_:LoaderData = new LoaderData();
         _loc3_.mFirstEvent = getTimer();
         _loc3_.mType = param1.mType;
         this.mLoadersData.push(_loc3_);
         this.mLoaderDict[param2] = _loc3_;
         return _loc3_;
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         var _loc3_:LoaderInfo = null;
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            _loc2_.mHTTPStatusText = param1.status.toString();
            _loc3_ = param1.target as LoaderInfo;
            if(_loc3_ != null)
            {
               _loc2_.mUrl = _loc3_.url;
            }
            _loc2_.mStatus = param1;
            if(_loc2_.mUrl == null)
            {
            }
         }
      }
      
      private function initHandler(param1:Event) : void
      {
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            _loc2_.mProgressText = Localization.Lbl_LA_Init;
            if(_loc2_.mUrl == null && _loc2_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc2_.mUrl = param1.target.url;
            }
         }
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc3_:Array = null;
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            _loc2_.mIOError = param1;
            _loc2_.mProgressText = Localization.Lbl_LA_IOError;
            if(_loc2_.mUrl == null)
            {
               _loc2_.mUrl = _loc2_.mIOError.text;
               _loc3_ = param1.text.split(Localization.Lbl_LA_URL);
               if(_loc3_.length > 1)
               {
                  _loc2_.mUrl = _loc3_[1];
               }
            }
         }
      }
      
      private function openHandler(param1:Event) : void
      {
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            if(_loc2_.mUrl == null && _loc2_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc2_.mUrl = param1.target.url;
            }
         }
      }
      
      private function progressHandler(param1:ProgressEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            _loc3_ = false;
            if(Configuration._PROFILE_MEMORY || Configuration._PROFILE_FUNCTION || Configuration._PROFILE_LOADERS || Configuration._PROFILE_INTERNAL_EVENTS || Boolean(Commands.mIsCollectingSamplesData))
            {
               _loc3_ = true;
               pauseSampling();
            }
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            if(param1.bytesTotal > 0)
            {
               _loc4_ = int(param1.bytesLoaded / param1.bytesTotal * 10000) / 100;
               if(_loc2_.mProgress > param1.bytesLoaded / param1.bytesTotal)
               {
                  _loc2_ = this.PreventReUse(_loc2_,param1.target);
               }
               _loc2_.mLoadedBytes = int(param1.bytesLoaded);
               _loc2_.mLoadedBytesText = String(int(param1.bytesLoaded));
               _loc2_.mProgress = param1.bytesLoaded / param1.bytesTotal;
               if(_loc4_ == 100)
               {
                  _loc2_.mProgressText = LoaderData.LOADER_STATUS_COMPLETED;
               }
               else
               {
                  _loc2_.mProgressText = _loc4_.toString() + Localization.Lbl_LA_Percent;
               }
            }
            else
            {
               if(_loc2_.mProgress > param1.bytesLoaded)
               {
                  _loc2_ = this.PreventReUse(_loc2_,param1.target);
               }
               _loc2_.mLoadedBytes = int(param1.bytesLoaded);
               _loc2_.mLoadedBytesText = String(param1.bytesLoaded);
               _loc2_.mProgress = param1.bytesLoaded;
               _loc2_.mProgressText = int(_loc2_.mProgress).toString();
            }
            if(_loc2_.mUrl == null && _loc2_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc2_.mUrl = param1.target.url;
            }
            if(_loc3_)
            {
               startSampling();
            }
         }
      }
      
      private function unLoadHandler(param1:Event) : void
      {
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            _loc2_.mProgressText = Localization.Lbl_LA_Unload;
            if(_loc2_.mUrl == null && _loc2_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc2_.mUrl = param1.target.url;
            }
         }
      }
      
      private function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         var _loc2_:LoaderData = this.mLoaderDict[param1.target];
         if(_loc2_ != null)
         {
            if(_loc2_.mFirstEvent == -1)
            {
               _loc2_.mFirstEvent = getTimer();
            }
            _loc2_.mSecurityError = param1;
            _loc2_.mProgressText = Localization.Lbl_LA_SecurityError;
            if(_loc2_.mUrl == null && _loc2_.mType == LoaderData.DISPLAY_LOADER)
            {
               _loc2_.mUrl = param1.target.url;
            }
            else
            {
               _loc2_.mUrl = _loc2_.mSecurityError.text;
            }
         }
      }
   }
}
