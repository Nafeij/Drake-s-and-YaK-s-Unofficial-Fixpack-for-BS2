package com.sociodox.theminer.manager
{
   import com.sociodox.theminer.TheMiner;
   import com.sociodox.theminer.window.Configuration;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.sampler.getSamples;
   import flash.sampler.startSampling;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.text.TextField;
   
   public class Launcher extends Sprite
   {
       
      
      private var mLoader:Loader;
      
      private var mMiner:TheMiner;
      
      private var mtext:TextField;
      
      public function Launcher()
      {
         super();
         if(stage)
         {
            this.Init();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE,this.Init);
         }
      }
      
      private function Init(param1:Event = null) : void
      {
         var _loc2_:* = undefined;
         this.stage.scaleMode = StageScaleMode.NO_SCALE;
         this.stage.align = StageAlign.TOP_LEFT;
         removeEventListener(Event.ADDED_TO_STAGE,this.Init);
         Configuration.ANALYTICS_ENABLED = true;
         Configuration.PROFILE_MEMORY = true;
         Configuration.PROFILE_FUNCTION = true;
         Configuration.PROFILE_INTERNAL_EVENTS = true;
         Configuration.PROFILE_LOADERS = true;
         Configuration.PROFILE_MEMGRAPH = true;
         if(this.loaderInfo.parameters["FileToLaunch"] != undefined)
         {
            startSampling();
            this.mLoader = new Loader();
            this.mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.OnFileLoaded);
            addChild(this.mLoader);
            this.mLoader.load(new URLRequest(this.loaderInfo.parameters["FileToLaunch"]),new LoaderContext(false,ApplicationDomain.currentDomain,SecurityDomain.currentDomain));
            _loc2_ = getSamples();
            trace(_loc2_);
         }
         else
         {
            trace("unable to find file to launch");
         }
      }
      
      private function OnFileLoaded(param1:Event) : void
      {
         Analytics.Track("Process","Launch","Launch/" + "1.4.01" + "/T");
         var _loc2_:Sprite = param1.target.content;
         _loc2_.x = this.stage.stageWidth / 2 - _loc2_.loaderInfo.width / 2;
         _loc2_.y = this.stage.stageHeight / 2 - _loc2_.loaderInfo.height / 2;
         this.mMiner = new TheMiner();
         param1.target.content.addChild(this.mMiner);
      }
   }
}
