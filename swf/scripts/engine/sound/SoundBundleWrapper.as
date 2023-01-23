package engine.sound
{
   import engine.sound.def.ISoundDef;
   import engine.sound.def.SoundDef;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SoundBundleWrapper extends EventDispatcher implements ISoundDefBundleListener
   {
       
      
      private var eventId:String;
      
      private var driver:ISoundDriver;
      
      private var bundle:ISoundDefBundle;
      
      private var playImmediately:Boolean;
      
      private var oneshot:Boolean;
      
      private var systemid:ISoundEventId;
      
      public function SoundBundleWrapper(param1:String, param2:String, param3:ISoundDriver, param4:Boolean = false, param5:Boolean = false)
      {
         super();
         this.eventId = param2;
         this.driver = param3;
         this.playImmediately = param4;
         this.oneshot = param5;
         var _loc6_:Vector.<ISoundDef> = new Vector.<ISoundDef>();
         var _loc7_:SoundDef = new SoundDef().setup(null,"bundle_wrapper-" + param1,param2);
         _loc6_.push(_loc7_);
         this.bundle = param3.preloadSoundDefData("bundle_wrapper-" + param1,_loc6_);
         this.bundle.addListener(this);
      }
      
      public static function oneshotSound(param1:String, param2:String, param3:ISoundDriver) : void
      {
         new SoundBundleWrapper(param1,param2,param3,true,true);
      }
      
      public function cleanup() : void
      {
         if(this.bundle)
         {
            this.bundle.removeListener(this);
            this.bundle = null;
         }
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
         if(this.playImmediately)
         {
            this.playSound();
         }
         if(this.oneshot)
         {
            this.cleanup();
         }
      }
      
      public function playSound() : void
      {
         if(this.driver && this.bundle && this.bundle.complete && this.bundle.ok)
         {
            this.systemid = this.driver.playEvent(this.eventId);
         }
      }
      
      public function stopSound() : void
      {
         if(Boolean(this.driver) && Boolean(this.systemid))
         {
            this.driver.stopEvent(this.systemid,false);
            this.systemid = null;
         }
      }
   }
}
