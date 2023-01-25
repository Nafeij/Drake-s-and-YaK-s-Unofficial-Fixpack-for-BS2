package engine.gui
{
   import engine.anim.AnimDispatcherEvent;
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.core.util.StringUtil;
   import engine.gui.core.GuiLabel;
   import engine.gui.core.GuiSprite;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneAudioEmitterAudible;
   import engine.sound.ISoundDriver;
   import engine.sound.ISoundEventId;
   import engine.sound.SoundDriverEvent;
   import engine.sound.config.ISoundSystem;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   
   public class GuiSoundDebug extends GuiSprite
   {
      
      public static var DEBUGGING:Boolean = false;
      
      public static const FONT:String = MonoFont.FONT;
      
      private static const COLOR_EVENT:int = 0;
      
      private static const COLOR_LAYER:int = 26214;
      
      private static const COLOR_PARAM:int = 6684825;
      
      private static const COLOR_PLAY:int = 34816;
      
      private static const COLOR_STOP:int = 2267528;
      
      private static const COLOR_END:int = 12272776;
      
      private static const COLOR_ANIM:int = 17561;
      
      private static const COLOR_ERROR:int = 16711680;
       
      
      public var ROW_HEIGHT:Number = 11;
      
      public var logger:ILogger;
      
      private var _driver:ISoundDriver;
      
      public var current:GuiLabel;
      
      public var sceneCurrent:GuiLabel;
      
      public var battle:GuiLabel;
      
      public var ticker:GuiLabel;
      
      private var dirty:Boolean;
      
      private var dirtySceneCurrent:Boolean;
      
      private var dirtyBattle:Boolean = true;
      
      private var _animDispatcher:EventDispatcher;
      
      private var container:GuiSprite;
      
      private var _scene:Scene;
      
      private var _soundConfig:ISoundSystem;
      
      private var logs:Array;
      
      private var _trauma:Number = 0;
      
      private var _battleCurrent:String;
      
      private var _battleNext:String;
      
      private var _battleCompleting:String;
      
      private var _winning:String;
      
      private var _battleShortUrl:String;
      
      public function GuiSoundDebug(param1:GuiSprite, param2:ILogger)
      {
         this.current = new GuiLabel(FONT,this.ROW_HEIGHT);
         this.sceneCurrent = new GuiLabel(FONT,this.ROW_HEIGHT);
         this.battle = new GuiLabel(FONT,this.ROW_HEIGHT);
         this.ticker = new GuiLabel(FONT,this.ROW_HEIGHT);
         this.logs = [];
         super();
         this.container = param1;
         name = "sound_debug";
         this.current.name = "current";
         this.ticker.name = "ticker";
         this.sceneCurrent.name = "sceneCurrent";
         this.battle.name = "battle";
         this.logger = param2;
         debugRender = 1728053247;
         anchor.left = 10;
         anchor.right = 10;
         y = 10;
         height = 300;
         this.current.y = 4;
         this.current.height = 200;
         this.current.debugRender = 2868903935;
         this.current.anchor.left = 4;
         this.current.anchor.percentWidth = 50;
         this.sceneCurrent.y = 4;
         this.sceneCurrent.height = 200;
         this.sceneCurrent.debugRender = 2868903935;
         this.sceneCurrent.anchor.right = 4;
         this.sceneCurrent.anchor.percentWidth = 50;
         this.ticker.y = this.current.y + this.current.height + 4;
         this.ticker.height = height - this.ticker.y - 4;
         this.ticker.anchor.left = 4;
         this.ticker.anchor.percentWidth = 50;
         this.battle.y = this.ticker.y;
         this.battle.height = this.ticker.height;
         this.battle.debugRender = 2868903935;
         this.battle.anchor.right = 4;
         this.battle.anchor.percentWidth = 50;
         this.ticker.debugRender = 2868903935;
         addChild(this.current);
         addChild(this.sceneCurrent);
         addChild(this.ticker);
         addChild(this.battle);
         layoutGuiSprite();
         visible = false;
         mouseEnabled = false;
         mouseChildren = false;
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.ticker.label.scrollRect = new Rectangle(0,0,this.ticker.width,this.ticker.height);
         this.current.label.scrollRect = new Rectangle(0,0,this.current.width,this.current.height);
         this.sceneCurrent.label.scrollRect = new Rectangle(0,0,this.sceneCurrent.width,this.sceneCurrent.height);
         this.battle.label.scrollRect = new Rectangle(0,0,this.battle.width,this.battle.height);
      }
      
      private function get driver() : ISoundDriver
      {
         return this._driver;
      }
      
      private function set driver(param1:ISoundDriver) : void
      {
         if(this._driver)
         {
            this._driver.removeEventListener(SoundDriverEvent.PLAY,this.playHandler);
            this._driver.removeEventListener(SoundDriverEvent.STOP,this.stopHandler);
            this._driver.removeEventListener(SoundDriverEvent.PARAM,this.paramHandler);
         }
         this._driver = param1;
         if(this._driver)
         {
            this._driver.addEventListener(SoundDriverEvent.PLAY,this.playHandler);
            this._driver.addEventListener(SoundDriverEvent.STOP,this.stopHandler);
            this._driver.addEventListener(SoundDriverEvent.PARAM,this.paramHandler);
         }
         this.dirty = true;
      }
      
      public function update(param1:int) : void
      {
         this.updateCurrent();
         this.updateSceneCurrent();
         this.updateBattle();
      }
      
      private function updateCurrent() : void
      {
         var _loc3_:Object = null;
         var _loc4_:ISoundEventId = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         if(!this._driver || !visible)
         {
            return;
         }
         this.dirty = false;
         var _loc1_:* = "";
         var _loc2_:String = ColorUtil.colorStr(COLOR_EVENT);
         for(_loc3_ in this._driver.playing)
         {
            _loc4_ = _loc3_ as ISoundEventId;
            _loc5_ = String(this._driver.playing[_loc4_]);
            if(_loc5_)
            {
               _loc6_ = _loc4_.toString();
               _loc1_ += "<font color=\"" + _loc2_ + "\">" + _loc6_ + ": " + _loc5_ + "</font> ";
               _loc7_ = this._driver.getEventTimelinePosition(_loc4_);
               _loc8_ = _loc7_ / 1000;
               _loc9_ = _loc8_ / 60;
               _loc10_ = (_loc7_ - _loc8_ * 1000) / 100;
               _loc8_ -= _loc9_ * 60;
               _loc1_ += StringUtil.padLeft(_loc9_.toString(),"0",2) + ":" + StringUtil.padLeft(_loc8_.toString(),"0",2) + "." + _loc10_ + " ";
               _loc11_ = this.makeParamString(_loc4_);
               if(_loc11_)
               {
                  _loc1_ += _loc11_;
               }
               _loc1_ += "\n";
            }
         }
         this.current.label.htmlText = _loc1_;
         this.current.label.height = this.current.height;
      }
      
      private function updateBattle() : void
      {
         if(!this._driver || !visible || !this.dirtyBattle)
         {
            return;
         }
         this.dirtyBattle = false;
         var _loc1_:String = "";
         _loc1_ += " Music Def: " + this._battleShortUrl + "\n";
         _loc1_ += "    Trauma: " + this._trauma.toFixed(2) + "\n";
         _loc1_ += "   Winning: " + this._winning + "\n";
         _loc1_ += "   Current: " + this._battleCurrent + "\n";
         _loc1_ += "Completing: " + this._battleCompleting + "\n";
         _loc1_ += "      Next: " + this._battleNext + "\n";
         this.battle.label.htmlText = _loc1_;
         this.battle.label.height = this.battle.height;
      }
      
      private function updateSceneCurrent() : void
      {
         var _loc5_:SceneAudioEmitterAudible = null;
         var _loc6_:ISoundEventId = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         if(!this._driver || !visible)
         {
            return;
         }
         if(!this._scene || !this._scene.audio || !this._scene.audio.audDefs)
         {
            if(this.sceneCurrent.label.text)
            {
               this.sceneCurrent.label.text = "";
            }
            return;
         }
         this.dirtySceneCurrent = false;
         var _loc1_:* = "";
         var _loc2_:String = ColorUtil.colorStr(COLOR_EVENT);
         var _loc3_:String = ColorUtil.colorStr(COLOR_LAYER);
         var _loc4_:String = ColorUtil.colorStr(COLOR_PARAM);
         for each(_loc5_ in this.scene.audio.auds)
         {
            if(!(!_loc5_.systemid || _loc5_.error))
            {
               if(_loc5_.emitter.event)
               {
                  _loc6_ = _loc5_.systemid;
                  _loc7_ = StringUtil.padRight(_loc5_.emitter.event," ",48);
                  _loc8_ = _loc6_.toString();
                  _loc1_ += _loc8_ + ": ";
                  _loc1_ += _loc7_;
                  if(_loc5_.emitter.layer)
                  {
                     _loc1_ += " <font color=\"" + _loc3_ + "\">(" + _loc5_.emitter.layer + ")</font> ";
                  }
                  _loc1_ += " <font color=\"" + _loc4_ + "\">v=" + _loc5_.volume.toFixed(2) + " p=" + StringUtil.numberWithSign(_loc5_.panX,2) + "</font>";
                  _loc1_ += "\n";
               }
            }
         }
         this.sceneCurrent.label.htmlText = _loc1_;
         this.sceneCurrent.label.height = this.current.height;
      }
      
      private function makeParamString(param1:ISoundEventId) : String
      {
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc2_:int = this.driver.getNumEventParameters(param1);
         if(_loc2_ <= 0)
         {
            return null;
         }
         var _loc3_:String = ColorUtil.colorStr(COLOR_PARAM);
         var _loc4_:* = "<font color=\"" + _loc3_ + "\">";
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_)
         {
            _loc6_ = this.driver.getEventParameterName(param1,_loc5_);
            _loc7_ = this.driver.getEventParameterValue(param1,_loc5_);
            _loc8_ = this.driver.getEventParameterVelocity(param1,_loc5_);
            _loc9_ = this.driver.getEventParameterSeekSpeed(param1,_loc5_);
            _loc4_ += "&nbsp;" + _loc6_ + "=" + _loc7_.toFixed(2);
            if(_loc8_)
            {
               _loc4_ += ", vel=" + _loc8_.toFixed(2);
            }
            if(_loc9_)
            {
               _loc4_ += ", seek=" + _loc9_.toFixed(2);
            }
            _loc4_ += " ";
            _loc5_++;
         }
         return _loc4_ + "</font>";
      }
      
      private function paramHandler(param1:SoundDriverEvent) : void
      {
         this.dirty = true;
         this.log("PARAM " + param1.eventName + " " + param1.param + "=" + this.driver.getParams(param1.eventName)[param1.param],COLOR_PARAM);
      }
      
      private function stopHandler(param1:SoundDriverEvent) : void
      {
         this.dirty = true;
         this.log("STOP  " + param1.systemid + ": " + param1.eventName,COLOR_STOP);
      }
      
      private function playHandler(param1:SoundDriverEvent) : void
      {
         this.dirty = true;
         if(this.driver.playing[param1.systemid])
         {
            this.log("PLAY  " + param1.systemid + ": " + param1.eventName,COLOR_PLAY);
         }
         else
         {
            this.log("END   " + param1.systemid + ": " + param1.eventName,COLOR_END);
         }
      }
      
      public function toggle() : void
      {
         this.logs.splice(0,this.logs.length);
         if(parent)
         {
            parent.removeChild(this);
            visible = false;
            DEBUGGING = false;
         }
         else
         {
            this.container.addChild(this);
            this.container.bringToFront();
            visible = true;
            DEBUGGING = true;
         }
         this.dirty = true;
      }
      
      public function log(param1:String, param2:int) : void
      {
         var _loc7_:Object = null;
         if(!visible)
         {
            return;
         }
         this.logger.debug("SOUND_DEBUG: " + param1);
         this.logs.push({
            "str":param1,
            "color":ColorUtil.colorStr(param2)
         });
         var _loc3_:String = "";
         var _loc4_:int = 13;
         var _loc5_:int = 0;
         var _loc6_:int = int(this.logs.length - 1);
         while(_loc6_ >= 0)
         {
            _loc7_ = this.logs[_loc6_];
            _loc3_ += _loc6_.toString() + "&nbsp;<font color=\"" + _loc7_.color + "\">" + _loc7_.str + "</font><br>\n";
            if(++_loc5_ >= 13)
            {
               break;
            }
            _loc6_--;
         }
         this.ticker.label.htmlText = _loc3_;
      }
      
      public function set animDispatcher(param1:EventDispatcher) : void
      {
         if(this._animDispatcher == param1)
         {
            return;
         }
         if(this._animDispatcher)
         {
            this._animDispatcher.removeEventListener(AnimDispatcherEvent.ANIM_EVENT,this.animDispatcherEvent);
            this._animDispatcher.removeEventListener(AnimDispatcherEvent.SOUND_ERROR,this.animDispatcherEvent);
            this._animDispatcher.removeEventListener(AnimDispatcherEvent.BATTLE_TRAUMA,this.animDispatcherEvent);
            this._animDispatcher.removeEventListener(AnimDispatcherEvent.FRONTIFY_GUI,this.animDispatcherEvent);
         }
         this._animDispatcher = param1;
         if(this._animDispatcher)
         {
            this._animDispatcher.addEventListener(AnimDispatcherEvent.ANIM_EVENT,this.animDispatcherEvent);
            this._animDispatcher.addEventListener(AnimDispatcherEvent.SOUND_ERROR,this.animDispatcherEvent);
            this._animDispatcher.addEventListener(AnimDispatcherEvent.BATTLE_TRAUMA,this.animDispatcherEvent);
            this._animDispatcher.addEventListener(AnimDispatcherEvent.FRONTIFY_GUI,this.animDispatcherEvent);
         }
      }
      
      private function animDispatcherEvent(param1:AnimDispatcherEvent) : void
      {
         if(param1.type == AnimDispatcherEvent.ANIM_EVENT)
         {
            if(Boolean(this._soundConfig) && this._soundConfig.mixer.sfxEnabled)
            {
               this.log("ANIM  " + param1.entity + " " + param1.id + " " + param1.animId + " " + param1.eventId,COLOR_ANIM);
            }
         }
         else if(param1.type == AnimDispatcherEvent.SOUND_ERROR)
         {
            this.log("SERR  " + param1.entity + " " + param1.id,COLOR_ERROR);
         }
         else if(param1.type == AnimDispatcherEvent.BATTLE_TRAUMA)
         {
            this._trauma = param1.value;
            this._battleCurrent = param1.id;
            this._battleNext = param1.animId;
            this._battleCompleting = param1.eventId;
            this._winning = param1.winning;
            this.dirtyBattle = true;
            this._battleShortUrl = param1.musicdef;
         }
         else if(param1.type == AnimDispatcherEvent.FRONTIFY_GUI)
         {
            bringToFront();
         }
      }
      
      public function get soundConfig() : ISoundSystem
      {
         return this._soundConfig;
      }
      
      public function set soundConfig(param1:ISoundSystem) : void
      {
         this._soundConfig = param1;
         this.driver = !!this._soundConfig ? this._soundConfig.driver : null;
      }
      
      public function get scene() : Scene
      {
         return this._scene;
      }
      
      public function set scene(param1:Scene) : void
      {
         this._scene = param1;
         this.updateSceneCurrent();
      }
   }
}
