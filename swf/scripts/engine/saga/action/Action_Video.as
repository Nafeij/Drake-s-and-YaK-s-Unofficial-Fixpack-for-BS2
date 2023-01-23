package engine.saga.action
{
   import engine.def.BooleanVars;
   import engine.saga.ISagaSound;
   import engine.saga.Saga;
   import engine.saga.VideoParams;
   import engine.sound.def.ISoundDef;
   
   public class Action_Video extends BaseAction_Sound
   {
       
      
      private var params:VideoParams;
      
      private var _waitingSounds:int = 0;
      
      private var _loadedSounds:int = 0;
      
      private var _initialized:Boolean;
      
      public function Action_Video(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      public static function parseVideoArgs(param1:String) : VideoParams
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc2_:VideoParams = new VideoParams();
         var _loc3_:Array = !!param1 ? param1.split(" ") : [];
         for each(_loc8_ in _loc3_)
         {
            if(_loc8_.indexOf("vo=") == 0)
            {
               _loc2_.vo = _loc8_.substr("vo=".length);
            }
            else if(_loc8_.indexOf("music=") == 0)
            {
               _loc2_.music = _loc8_.substr("music=".length);
            }
            else if(_loc8_.indexOf("supertitle=") == 0)
            {
               _loc2_.supertitle = _loc8_.substr("supertitle=".length);
            }
            else if(_loc8_.indexOf("startkillmusic=") == 0)
            {
               _loc2_.startkillmusic = BooleanVars.parse(_loc8_.substr("startkillmusic=".length),_loc2_.startkillmusic);
            }
            else
            {
               if(_loc8_ != "noskip")
               {
                  throw new ArgumentError("Invalid arg [" + _loc8_ + "] in param [" + param1 + "]");
               }
               _loc2_.noskip = true;
            }
         }
         return _loc2_;
      }
      
      private static function _loadSoundEvent(param1:String, param2:ISagaSound) : ISoundDef
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return null;
         }
         _loc3_ = param2.system.driver.inferSkuFromEventPath(_loc3_);
         return param2.getSoundDef(_loc3_,param1);
      }
      
      public static function getSoundDefsForActionDef(param1:ActionDef, param2:ISagaSound, param3:Vector.<ISoundDef>) : Vector.<ISoundDef>
      {
         var _loc4_:VideoParams = parseVideoArgs(param1.param);
         var _loc5_:ISoundDef = _loadSoundEvent(_loc4_.vo,param2);
         var _loc6_:ISoundDef = _loadSoundEvent(_loc4_.music,param2);
         if(Boolean(_loc5_) || Boolean(_loc6_))
         {
            if(!param3)
            {
               param3 = new Vector.<ISoundDef>();
            }
            _loc5_ && param3.push(_loc5_);
            _loc6_ && param3.push(_loc6_);
         }
         return param3;
      }
      
      override protected function handleStarted() : void
      {
         this.params = parseVideoArgs(def.param);
         this.params.vo && startLoadingSound(null,this.params.vo,null,0);
         this.params.music && startLoadingSound(null,this.params.music,null,0);
         this._waitingSounds += !!this.params.vo ? 1 : 0;
         this._waitingSounds += !!this.params.music ? 1 : 0;
         this.params.subtitle = def.subtitle;
         this.params.url = def.url;
         this._initialized = true;
         this._checkPerformVideo();
      }
      
      override protected function handlePlaySound() : Boolean
      {
         ++this._loadedSounds;
         if(this._initialized)
         {
            this._checkPerformVideo();
         }
         return true;
      }
      
      private function _checkPerformVideo() : void
      {
         if(this._initialized)
         {
            if(this._waitingSounds <= this._loadedSounds)
            {
               this.performVideo();
            }
         }
      }
      
      private function performVideo() : void
      {
         saga.performVideo(this.params);
      }
      
      override public function triggerVideoFinished(param1:String) : void
      {
         if(Boolean(this.params) && param1 == this.params.url)
         {
            end();
         }
      }
      
      final override protected function handleEnded() : void
      {
         super.handleEnded();
      }
   }
}
