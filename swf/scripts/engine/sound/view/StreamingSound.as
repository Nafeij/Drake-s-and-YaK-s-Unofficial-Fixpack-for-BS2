package engine.sound.view
{
   import engine.core.logging.ILogger;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.def.ISoundDef;
   
   public class StreamingSound implements ISound
   {
       
      
      private var _def:ISoundDef;
      
      private var _finishedCallback:Function;
      
      public var soundDriver:ISoundDriver;
      
      public var logger:ILogger;
      
      private var _systemid:ISoundEventId = null;
      
      public function StreamingSound(param1:ISoundDef, param2:ISoundDriver, param3:Function, param4:ILogger)
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
            return "[" + this._def.soundName + "]";
         }
         return "[null]";
      }
      
      public function get def() : ISoundDef
      {
         return this._def;
      }
      
      public function isLooping() : Boolean
      {
         throw new ArgumentError("StreamingSound.isLooping not implemented");
      }
      
      public function get playing() : Boolean
      {
         throw new ArgumentError("StreamingSound.playing not implemented");
      }
      
      public function start() : void
      {
         this._systemid = this.soundDriver.playEvent(this._def.eventName);
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
         this.soundDriver.setEventParameter(this.def.eventName,param1,param2);
      }
      
      public function getParameter(param1:String) : Number
      {
         return this.soundDriver.getEventParameter(this.def.eventName,param1);
      }
      
      public function setVolume(param1:Number) : void
      {
      }
   }
}
