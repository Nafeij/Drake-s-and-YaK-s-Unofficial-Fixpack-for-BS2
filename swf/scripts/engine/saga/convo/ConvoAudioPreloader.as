package engine.saga.convo
{
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdDef;
   import engine.saga.convo.def.audio.ConvoAudioCmdsDef;
   import engine.saga.convo.def.audio.ConvoAudioDef;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ConvoAudioPreloader extends EventDispatcher implements ISoundDefBundleListener
   {
       
      
      public var audio:ConvoAudioListDef;
      
      public var convo:Convo;
      
      public var complete:Boolean;
      
      private var bundle:ISoundDefBundle;
      
      public var driver:ISoundDriver;
      
      private var logger:ILogger;
      
      private var waitingForSoundsToFinish:Dictionary;
      
      public function ConvoAudioPreloader(param1:ISoundDriver, param2:ConvoAudioListDef, param3:Convo, param4:ILogger)
      {
         super();
         this.audio = param2;
         this.convo = param3;
         this.driver = param1;
         this.logger = param4;
      }
      
      public function preload() : void
      {
         if(this.logger.isDebugEnabled)
         {
         }
         var _loc1_:Vector.<ISoundDef> = this.getSoundDefs();
         if(Boolean(_loc1_) && _loc1_.length > 0)
         {
            this.bundle = this.driver.preloadSoundDefData(this.convo.def.url,_loc1_);
            this.bundle.addListener(this);
         }
         else
         {
            this.soundDefBundleComplete(null);
         }
      }
      
      private function addActorFoley(param1:String, param2:Vector.<ISoundDef>) : Vector.<ISoundDef>
      {
         var _loc3_:IEntityDef = null;
         if(param1)
         {
            _loc3_ = this.convo.saga.getCastMember(param1);
            if(_loc3_)
            {
               param2 = this.addSoundDef("common",_loc3_.appearance.portraitFoley,param2);
            }
         }
         return param2;
      }
      
      private function addSoundDef(param1:String, param2:String, param3:Vector.<ISoundDef>) : Vector.<ISoundDef>
      {
         var _loc4_:SoundDef = null;
         if(this.logger.isDebugEnabled)
         {
         }
         if(param2)
         {
            if(!param3)
            {
               param3 = new Vector.<ISoundDef>();
            }
            _loc4_ = new SoundDef().setup(param1,param2,param2);
            param3.push(_loc4_);
         }
         return param3;
      }
      
      private function getSoundDefs() : Vector.<ISoundDef>
      {
         var _loc1_:Vector.<ISoundDef> = null;
         var _loc3_:Vector.<String> = null;
         var _loc4_:String = null;
         var _loc5_:ConvoAudioDef = null;
         var _loc6_:ConvoAudioCmdsDef = null;
         var _loc7_:ConvoAudioCmdDef = null;
         var _loc2_:int = 1;
         while(_loc2_ <= 4)
         {
            _loc3_ = this.convo.def.getUnitsFromMark(_loc2_);
            for each(_loc4_ in _loc3_)
            {
               if(_loc4_)
               {
                  _loc1_ = this.addActorFoley(_loc4_,_loc1_);
               }
            }
            _loc2_++;
         }
         if(this.logger.isDebugEnabled)
         {
         }
         if(this.audio)
         {
            _loc5_ = this.audio.getAudioForConvo(this.convo.def.url);
            if(this.logger.isDebugEnabled)
            {
            }
            if(_loc5_ && _loc5_.cmdss && _loc5_.cmdss.length > 0)
            {
               for each(_loc6_ in _loc5_.cmdss)
               {
                  if(this.logger.isDebugEnabled)
                  {
                  }
                  for each(_loc7_ in _loc6_.cmds)
                  {
                     if(this.logger.isDebugEnabled)
                     {
                     }
                     _loc1_ = this.addSoundDef(_loc7_.sku,_loc7_.event,_loc1_);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.complete = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function cleanup() : void
      {
         if(this.bundle)
         {
            this.bundle.removeListener(this);
         }
      }
      
      public function waitForSoundToFinish(param1:ISoundEventId) : void
      {
         if(this.bundle)
         {
            this.bundle.waitForSoundToFinish(param1);
         }
      }
   }
}
