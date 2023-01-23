package game.cfg
{
   import com.greensock.TweenMax;
   import engine.core.logging.ILogger;
   import engine.sound.ISoundDriver;
   import engine.sound.config.ISoundSystem;
   
   public class FmodTestDropout
   {
       
      
      public var logger:ILogger;
      
      public var driver:ISoundDriver;
      
      public var fauxScene_1:FauxScene;
      
      public var fauxScene_2:FauxScene;
      
      public function FmodTestDropout(param1:ILogger, param2:ISoundSystem)
      {
         super();
         this.logger = param1;
         this.driver = param2.driver;
         this.driver.debugSoundDriver = true;
         param1.isDebugEnabled = true;
         this.start();
      }
      
      private function start() : void
      {
         this.fauxScene_1 = new FauxScene(this.driver,this.logger,"faux_one","world_saga3/ambience_chapter_16/vlg_arberrang_2d","world_saga3/ambience_chapter_16/vlg_arberrang_3d");
         TweenMax.delayedCall(5,function():void
         {
            fauxScene_1.stopBundle();
            TweenMax.delayedCall(2,function():void
            {
               fauxScene_1.release();
               fauxScene_2 = new FauxScene(driver,logger,"faux_two","world_saga3/ambience_chapter_21/arberrang/stg_blackrock_return3_2d","world_saga3/ambience_chapter_21/arberrang/stg_blackrock_return3_3d");
            });
         });
      }
   }
}

import engine.core.logging.ILogger;
import engine.sound.ISoundDefBundle;
import engine.sound.ISoundDefBundleListener;
import engine.sound.ISoundDriver;
import engine.sound.ISoundEventId;
import engine.sound.def.ISoundDef;
import engine.sound.def.SoundDef;

class FauxScene implements ISoundDefBundleListener
{
    
   
   public var bundle:ISoundDefBundle;
   
   public var systemids:Vector.<ISoundEventId>;
   
   public var driver:ISoundDriver;
   
   public var logger:ILogger;
   
   public var bundleId:String;
   
   public function FauxScene(param1:ISoundDriver, param2:ILogger, param3:String, param4:String, param5:String)
   {
      this.systemids = new Vector.<ISoundEventId>();
      super();
      param2.info(" ============================= Loading scene: " + param3);
      this.driver = param1;
      this.logger = param2;
      this.bundleId = param3;
      var _loc6_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
      _loc6_.push(new SoundDef().setup(null,param4,param4));
      _loc6_.push(new SoundDef().setup(null,param5,param5));
      this.bundle = param1.preloadSoundDefData(param3,_loc6_);
      this.bundle.addListener(this);
   }
   
   public function soundDefBundleComplete(param1:ISoundDefBundle) : void
   {
      var _loc2_:ISoundDef = null;
      var _loc3_:ISoundEventId = null;
      this.logger.info(" ============================= Bundle loaded and ready: " + this.bundleId);
      for each(_loc2_ in param1.defs)
      {
         _loc3_ = this.driver.playEvent(_loc2_.eventName);
         this.systemids.push(_loc3_);
      }
   }
   
   public function stopBundle() : void
   {
      var _loc1_:ISoundEventId = null;
      this.logger.info(" ============================= Stopping scene: " + this.bundleId);
      for each(_loc1_ in this.systemids)
      {
         this.driver.stopEvent(_loc1_,false);
      }
      this.systemids = new Vector.<ISoundEventId>();
   }
   
   public function release() : void
   {
      this.logger.info(" ============================= Releasing scene: " + this.bundleId);
      this.bundle.removeListener(this);
   }
}
