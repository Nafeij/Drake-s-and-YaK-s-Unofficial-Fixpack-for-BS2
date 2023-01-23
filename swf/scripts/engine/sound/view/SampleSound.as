package engine.sound.view
{
   import engine.core.logging.ILogger;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.NullSoundDriver;
   import engine.sound.def.ISoundDef;
   
   public class SampleSound implements ISound
   {
       
      
      private var _def:ISoundDef;
      
      private var _finishedCallback:Function;
      
      public var soundDriver:ISoundDriver;
      
      public var logger:ILogger;
      
      private var _systemid:ISoundEventId = null;
      
      public function SampleSound(param1:ISoundDef, param2:ISoundDriver, param3:Function, param4:ILogger)
      {
         super();
         this._def = param1;
         this._finishedCallback = param3;
         this.soundDriver = param2;
         this.logger = param4;
      }
      
      public function get systemid() : ISoundEventId
      {
         return this._systemid;
      }
      
      public function toString() : String
      {
         if(this._def)
         {
            return "[" + this._def.soundName + ":" + this._def.eventName + ":" + this._systemid + "]";
         }
         return "[null]";
      }
      
      public function get def() : ISoundDef
      {
         return this._def;
      }
      
      public function isLooping() : Boolean
      {
         if(this._systemid)
         {
            return this.soundDriver.isLooping(this._systemid);
         }
         return false;
      }
      
      public function get playing() : Boolean
      {
         if(this._systemid)
         {
            return this.soundDriver.isPlaying(this._systemid);
         }
         return false;
      }
      
      public function start() : void
      {
         if(this.soundDriver is NullSoundDriver)
         {
            return;
         }
         var _loc1_:String = this._def.eventName;
         if(!_loc1_)
         {
            return;
         }
         this._systemid = this.soundDriver.playEvent(_loc1_);
         if(this._systemid)
         {
         }
      }
      
      public function stop(param1:Boolean) : void
      {
         if(this._systemid)
         {
            this.soundDriver.stopEvent(this._systemid,param1);
            this._systemid = null;
         }
      }
      
      public function restart() : void
      {
         this.stop(true);
         this.start();
      }
      
      public function setParameter(param1:String, param2:Number) : void
      {
         if(this._systemid)
         {
            this.soundDriver.setEventParameterValueByName(this._systemid,param1,param2);
         }
      }
      
      public function getParameter(param1:String) : Number
      {
         if(this._systemid)
         {
            this.soundDriver.getEventParameterValueByName(this._systemid,param1);
         }
         return 0;
      }
      
      public function setVolume(param1:Number) : void
      {
         if(this._systemid)
         {
            this.soundDriver.setEventVolume(this._systemid,param1);
         }
      }
   }
}
