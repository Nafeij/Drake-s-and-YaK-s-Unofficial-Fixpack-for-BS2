package engine.sound.view
{
   import engine.core.logging.ILogger;
   import engine.sound.ISoundDefBundle;
   import engine.sound.ISoundDefBundleListener;
   import engine.sound.ISoundDriver;
   import engine.sound.def.ISoundDef;
   import engine.sound.def.ISoundLibrary;
   
   public class SoundController implements ISoundController, ISoundDefBundleListener
   {
       
      
      private var logger:ILogger;
      
      private var _loadCompleteCallback:Function;
      
      private var _library:ISoundLibrary;
      
      private var _soundDriver:ISoundDriver;
      
      private var id:String;
      
      private var soundDefBundle:ISoundDefBundle;
      
      private var _complete:Boolean;
      
      public function SoundController(param1:String, param2:ISoundDriver, param3:Function, param4:ILogger)
      {
         super();
         this.id = param1;
         this.logger = param4;
         this._loadCompleteCallback = param3;
         this._soundDriver = param2;
         if(!this._soundDriver)
         {
            throw new ArgumentError("Sound driver cannot be null");
         }
      }
      
      public function cleanup() : void
      {
         this._loadCompleteCallback = null;
         this._soundDriver = null;
         this.library = null;
      }
      
      public function get library() : ISoundLibrary
      {
         return this._library;
      }
      
      public function set library(param1:ISoundLibrary) : void
      {
         if(this._library == param1)
         {
            return;
         }
         if(this.soundDefBundle)
         {
            this.soundDefBundle.removeListener(this);
            this.soundDefBundle = null;
         }
         this._library = param1;
         if(this._library)
         {
            this.soundDefBundle = this._soundDriver.preloadSoundDefData(this._library.url,this._library.getAllSoundDefs(null));
            this.soundDefBundle.addListener(this);
         }
      }
      
      public function toString() : String
      {
         return this.id;
      }
      
      public function soundDefBundleComplete(param1:ISoundDefBundle) : void
      {
         this.complete = true;
         var _loc2_:Function = this._loadCompleteCallback;
         this._loadCompleteCallback = null;
         if(_loc2_ != null)
         {
            _loc2_(this);
         }
      }
      
      public function playSound(param1:String, param2:Function) : ISound
      {
         if(!this.complete || !this._soundDriver || !this._library)
         {
            return null;
         }
         var _loc3_:ISound = this.getSound(param1,param2);
         if(!_loc3_)
         {
            this.logger.error("SoundController.playSound " + this.id + " could not find sound to play: [" + param1 + "]");
         }
         else if(_loc3_.def.eventName)
         {
            _loc3_.start();
         }
         else
         {
            _loc3_ = null;
         }
         return _loc3_;
      }
      
      public function getSound(param1:String, param2:Function, param3:Boolean = true) : ISound
      {
         if(!this._library || !this.complete)
         {
            return null;
         }
         var _loc4_:ISoundDef = this._library.getSoundDef(param1);
         if(!_loc4_)
         {
            if(param3)
            {
               this.logger.error("SoundController.getSound: [" + this.id + "] failed to get sound definition for [" + param1 + "]");
            }
            return null;
         }
         if(_loc4_.isStream)
         {
            return new StreamingSound(_loc4_,this._soundDriver,param2,this.logger);
         }
         return new SampleSound(_loc4_,this._soundDriver,param2,this.logger);
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function set complete(param1:Boolean) : void
      {
         this._complete = param1;
      }
      
      public function get soundDriver() : ISoundDriver
      {
         return this._soundDriver;
      }
   }
}
