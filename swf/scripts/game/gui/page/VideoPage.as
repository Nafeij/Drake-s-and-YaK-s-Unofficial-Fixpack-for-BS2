package game.gui.page
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.FsmEvent;
   import engine.core.fsm.State;
   import engine.core.fsm.StatePhase;
   import engine.core.gp.GpControlButton;
   import engine.core.render.FitConstraints;
   import engine.core.util.StringUtil;
   import engine.gui.page.PageState;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.sound.config.ISoundMixer;
   import engine.sound.config.ISoundSystem;
   import engine.sound.def.SoundDef;
   import engine.sound.view.ISound;
   import engine.subtitle.SubtitleSequence;
   import engine.subtitle.SubtitleSequenceResource;
   import flash.events.NetStatusEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.VideoState;
   
   public class VideoPage extends GamePage
   {
      
      public static var VIDEO_DISABLED:Boolean = false;
      
      public static var startupCorrectionFunc:Function = null;
      
      public static var VIDEO_FIT:FitConstraints = new FitConstraints().setupMax(2731,1536).setupMin(2731,1536);
      
      public static var VIDEO_WIDTH:int = 2731;
      
      public static var VIDEO_HEIGHT:int = 1536;
      
      public static var CINEMASCOPE:Boolean;
       
      
      private var v:Video;
      
      private var nc:NetConnection;
      
      private var ns:NetStream;
      
      public var resman:ResourceManager;
      
      private var url:String;
      
      public var shorturl:String;
      
      private var video_escape:Cmd;
      
      private var video_pause:Cmd;
      
      private var video_restart:Cmd;
      
      private var video_left:Cmd;
      
      private var video_right:Cmd;
      
      private var cmd_back:Cmd;
      
      private var subtitle_seq:SubtitleSequence;
      
      private var subtitle_r:SubtitleSequenceResource;
      
      private var supertitle_seq:SubtitleSequence;
      
      private var supertitle_r:SubtitleSequenceResource;
      
      private var noskip:Boolean;
      
      private var volume:Number = -1;
      
      private var _soundVo:ISound;
      
      private var _soundMusic:ISound;
      
      public function VideoPage(param1:GameConfig)
      {
         this.video_escape = new Cmd("video_escape",this.cmdEscapeFunc);
         this.video_pause = new Cmd("video_pause",this.cmdPauseFunc);
         this.video_restart = new Cmd("video_restart",this.cmdRestartFunc);
         this.video_left = new Cmd("video_left",this.cmdLeftFunc);
         this.video_right = new Cmd("video_right",this.cmdRightFunc);
         this.cmd_back = new Cmd("video_back",this.cmdBackFunc);
         super(param1,VIDEO_FIT.maxWidth,VIDEO_FIT.maxHeight,true);
         this.resman = param1.resman;
         fitConstraints.copyFrom(VIDEO_FIT);
         fitConstraints.cinemascope = CINEMASCOPE;
         this.opaqueBackground = 0;
      }
      
      override protected function handleStart() : void
      {
         config.globalAmbience.audio = null;
         var _loc1_:VideoState = config.fsm.current as VideoState;
         if(VIDEO_DISABLED)
         {
            logger.info("VideoPage.VIDEO_DISABLED skipping video " + _loc1_);
            if(_loc1_)
            {
               _loc1_.handleVideoComplete();
            }
            return;
         }
         config.context.appInfo.setSystemIdleKeepAwake(true);
         config.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.noskip = _loc1_.vp.noskip;
         if(!_loc1_.vp.noskip)
         {
            config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.video_escape,KeyBindGroup.VIDEO);
            config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_back,KeyBindGroup.VIDEO);
            config.gpbinder.bindPress(GpControlButton.B,this.video_escape,KeyBindGroup.VIDEO);
         }
         var _loc2_:Boolean = config.options.developer;
         if(_loc2_)
         {
            config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.video_escape,KeyBindGroup.VIDEO);
            config.keybinder.bind(false,false,false,Keyboard.SPACE,this.video_pause,KeyBindGroup.VIDEO);
            config.keybinder.bind(false,false,false,Keyboard.LEFT,this.video_left,KeyBindGroup.VIDEO);
            config.keybinder.bind(false,false,false,Keyboard.RIGHT,this.video_right,KeyBindGroup.VIDEO);
         }
         if(_loc1_.vp.subtitle)
         {
            this.subtitle_r = this.resman.getResource(_loc1_.vp.subtitle,SubtitleSequenceResource) as SubtitleSequenceResource;
            this.subtitle_r.addResourceListener(this.subtitleSequenceHandler);
         }
         if(_loc1_.vp.supertitle)
         {
            this.supertitle_r = this.resman.getResource(_loc1_.vp.supertitle,SubtitleSequenceResource) as SubtitleSequenceResource;
            this.supertitle_r.addResourceListener(this.supertitleSequenceHandler);
         }
         this.checkSituation();
      }
      
      override protected function handleStateChanged() : void
      {
         logger.info("VideoPage.handleStateChanged " + state.name);
         this.checkSituation();
      }
      
      private function subtitleSequenceHandler(param1:ResourceLoadedEvent) : void
      {
         this.subtitle_seq = this.subtitle_r.sequence;
         this.subtitle_r.removeResourceListener(this.subtitleSequenceHandler);
         this.subtitle_r.release();
         this.subtitle_r = null;
         this.checkSituation();
      }
      
      private function supertitleSequenceHandler(param1:ResourceLoadedEvent) : void
      {
         this.supertitle_seq = this.supertitle_r.sequence;
         this.supertitle_r.removeResourceListener(this.supertitleSequenceHandler);
         this.supertitle_r.release();
         this.supertitle_r = null;
         this.checkSituation();
      }
      
      private function cmdEscapeFunc(param1:CmdExec) : void
      {
         var _loc2_:VideoState = config.fsm.current as VideoState;
         if(!_loc2_ || _loc2_.phase != StatePhase.ENTERED)
         {
            return;
         }
         if(Boolean(_loc2_.vp) && _loc2_.vp.noskip)
         {
            return;
         }
         this.stopSubtitlesSupertitles();
         this.stopVo();
         this.stopMusic();
         if(this.ns)
         {
            this.ns.pause();
         }
         _loc2_.handleVideoComplete();
         if(this.resman)
         {
            this.resman.releaseVideoUrl(_loc2_.url_actual);
         }
      }
      
      override protected function handleButtonClosePress() : void
      {
         this.cmdEscapeFunc(null);
      }
      
      override protected function handleTap() : void
      {
         var _loc1_:VideoState = config.fsm.current as VideoState;
         if(!_loc1_ || !_loc1_.vp || !_loc1_.vp.noskip)
         {
            showButtonClose(3);
         }
      }
      
      private function cmdPauseFunc(param1:CmdExec) : void
      {
         if(!this.ns)
         {
         }
      }
      
      private function cmdBackFunc(param1:CmdExec) : void
      {
         if(isCloseButtonShowing())
         {
            this.cmdEscapeFunc(null);
         }
         else if(this.ns)
         {
            this.ns.seek(0);
         }
      }
      
      private function cmdRestartFunc(param1:CmdExec) : void
      {
         if(this.ns)
         {
            this.ns.seek(0);
         }
      }
      
      private function cmdLeftFunc(param1:CmdExec) : void
      {
         if(this.ns)
         {
            this.ns.step(this.ns.time - 1);
         }
      }
      
      private function cmdRightFunc(param1:CmdExec) : void
      {
         if(this.ns)
         {
            this.ns.step(this.ns.time + 1);
         }
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
         if(cleanedup)
         {
            return;
         }
         this.checkSituation();
      }
      
      private function checkSituation() : void
      {
         var vs:VideoState;
         var furl:String = null;
         if(cleanedup)
         {
            return;
         }
         if(VIDEO_DISABLED)
         {
            logger.info("VideoPage.checkSituation VIDEO_DISABLED");
            return;
         }
         if(state != PageState.READY)
         {
            logger.debug("VideoPage.checkSituation UNREADY " + state);
            return;
         }
         vs = config.fsm.current as VideoState;
         if(!vs)
         {
            logger.debug("VideoPage.checkSituation !VideoState");
            return;
         }
         if(this.v || this.ns || Boolean(this.nc))
         {
            logger.debug("VideoPage.checkSituation already waiting v=" + this.v + ", ns=" + this.ns + ", nc=" + this.nc);
            return;
         }
         if(Boolean(this.subtitle_r) && !this.subtitle_seq)
         {
            logger.debug("VideoPage.checkSituation subtitles unready");
            return;
         }
         if(Boolean(this.supertitle_r) && !this.supertitle_seq)
         {
            logger.debug("VideoPage.checkSituation supertitles unready");
            return;
         }
         if(PlatformStarling.instance)
         {
            PlatformStarling.instance.pause3D();
         }
         try
         {
            this.v = new Video(VIDEO_WIDTH,VIDEO_HEIGHT);
            this.nc = new NetConnection();
            this.nc.connect(null);
            this.ns = new NetStream(this.nc);
            this.ns.client = {"onMetadata":function(param1:Object):void
            {
            }};
            this.ns.inBufferSeek = true;
            this.v.attachNetStream(this.ns);
            addChildToContainer(this.v);
            this.v.x = -this.v.width / 2;
            this.v.y = -this.v.height / 2;
            this.v.smoothing = true;
            furl = this.resman.getVideoUrl(vs.url_actual);
            this.url = vs.url_actual;
            this.shorturl = StringUtil.getBasename(furl);
            this.ns.addEventListener(NetStatusEvent.NET_STATUS,this.netStatusHandler);
            this.checkMuteStatus();
            percentLoaded = 0;
            this.state = PageState.LOADING;
            logger.info("VideoPage starting [" + vs.url_actual + "]: " + furl + " volume " + this.volume);
            this.ns.play(furl);
         }
         catch(err:Error)
         {
            logger.error("ERROR " + err.getStackTrace());
            if(PlatformStarling.instance)
            {
               PlatformStarling.instance.resume();
            }
         }
      }
      
      private function netStatusHandler(param1:NetStatusEvent) : void
      {
         if(logger)
         {
            logger.debug("VideoPage netStatus [" + this.shorturl + "] " + param1.info.code + ", level=" + param1.info.level);
         }
         if(cleanedup)
         {
            return;
         }
         var _loc2_:VideoState = config.fsm.current as VideoState;
         if(param1.info.code == "NetStream.Play.Stop")
         {
            this.eliminateOldVideo();
            if(_loc2_)
            {
               _loc2_.handleVideoComplete();
               if(this.resman)
               {
                  this.resman.releaseVideoUrl(_loc2_.url_actual);
               }
            }
            if(PlatformStarling.instance)
            {
               PlatformStarling.instance.resume();
            }
         }
         else if(param1.info.level == "error")
         {
            logger.error("netStatusHandler: " + param1.info.code + ": " + this.shorturl);
            if(_loc2_)
            {
               _loc2_.handleVideoComplete();
               if(this.resman)
               {
                  this.resman.releaseVideoUrl(_loc2_.url_actual);
               }
            }
            if(PlatformStarling.instance)
            {
               PlatformStarling.instance.resume();
            }
         }
         else if(param1.info.code == "NetStream.Play.Failed")
         {
            logger.error("netStatusHandler: " + param1.info.code + ": " + this.shorturl);
         }
         else if(param1.info.code == "NetStream.Play.Start")
         {
            percentLoaded = 100;
            this.state = PageState.READY;
            if(this.subtitle_seq)
            {
               config.ccs.subtitle.sequence = this.subtitle_seq;
            }
            if(this.supertitle_seq)
            {
               config.ccs.supertitle.sequence = this.supertitle_seq;
            }
            this.attemptSounds();
            if(startupCorrectionFunc != null)
            {
               startupCorrectionFunc();
            }
         }
         else if(param1.info.code == "NetStream.Buffer.Full")
         {
         }
      }
      
      private function attemptSounds() : void
      {
         var _loc1_:VideoState = config.fsm.current as VideoState;
         var _loc2_:Saga = config.saga;
         if(_loc1_.vp.startkillmusic)
         {
            _loc2_.sound.system.music = null;
         }
         var _loc3_:SoundDef = this.createSoundDef(!!_loc1_ ? _loc1_.vp.vo : null);
         if(_loc3_)
         {
            this._soundVo = _loc2_.sound.system.playVoDef(_loc3_);
         }
         var _loc4_:SoundDef = this.createSoundDef(!!_loc1_ ? _loc1_.vp.music : null);
         if(_loc4_)
         {
            this._soundMusic = _loc2_.sound.system.playMusicDef(_loc4_);
         }
      }
      
      private function createSoundDef(param1:String) : SoundDef
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:Saga = config.saga;
         if(!_loc2_ || !_loc2_.sound || !_loc2_.sound.system)
         {
            return null;
         }
         return new SoundDef().setup(null,param1,param1);
      }
      
      override public function cleanup() : void
      {
         config.context.appInfo.setSystemIdleKeepAwake(false);
         config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         config.gpbinder.unbind(this.video_escape);
         config.keybinder.unbind(this.cmd_back);
         config.keybinder.unbind(this.video_escape);
         config.keybinder.unbind(this.video_restart);
         config.keybinder.unbind(this.video_pause);
         config.keybinder.unbind(this.video_left);
         config.keybinder.unbind(this.video_right);
         this.cmd_back.cleanup();
         this.video_escape.cleanup();
         this.video_restart.cleanup();
         this.video_pause.cleanup();
         this.video_left.cleanup();
         this.video_right.cleanup();
         this.cmd_back = null;
         this.video_escape = null;
         this.video_restart = null;
         this.video_pause = null;
         this.video_left = null;
         this.video_right = null;
         this.eliminateOldVideo();
         if(!this.noskip)
         {
            config.ccs.subtitle.stopSequence(this.subtitle_seq);
            config.ccs.supertitle.stopSequence(this.supertitle_seq);
         }
         this.resman.releaseVideoUrl(this.url);
         this.resman = null;
         super.cleanup();
      }
      
      private function stopSubtitlesSupertitles() : void
      {
         if(this.subtitle_seq)
         {
            config.ccs.subtitle.stopSequence(this.subtitle_seq);
         }
         if(this.supertitle_seq)
         {
            config.ccs.supertitle.stopSequence(this.supertitle_seq);
         }
      }
      
      private function stopVo() : void
      {
         var _loc1_:Saga = Saga.instance;
         if(this._soundVo)
         {
            if(_loc1_)
            {
               _loc1_.sound.system.vo = null;
            }
            else if(this._soundVo.playing)
            {
               this._soundVo.stop(false);
            }
            this._soundVo = null;
         }
      }
      
      private function stopMusic() : void
      {
         var _loc1_:Saga = Saga.instance;
         if(this._soundMusic)
         {
            if(_loc1_)
            {
               _loc1_.sound.system.music = null;
            }
            else if(this._soundMusic.playing)
            {
               this._soundMusic.stop(false);
            }
            this._soundMusic = null;
         }
      }
      
      private function eliminateOldVideo() : void
      {
         percentLoaded = 100;
         if(this.v)
         {
            removeChildFromContainer(this.v);
            this.v = null;
         }
         if(this.ns)
         {
            this.ns.removeEventListener(NetStatusEvent.NET_STATUS,this.netStatusHandler);
            this.ns.pause();
            this.ns.dispose();
            this.ns = null;
         }
         if(this.nc)
         {
            if(PlatformStarling.instance)
            {
               PlatformStarling.instance.resume();
            }
            this.nc.close();
            this.nc = null;
         }
      }
      
      override public function canReusePageForState(param1:State) : Boolean
      {
         return false;
      }
      
      private function checkMuteStatus() : void
      {
         var _loc1_:ISoundSystem = null;
         var _loc2_:ISoundMixer = null;
         var _loc3_:Number = NaN;
         if(this.ns)
         {
            _loc1_ = config.soundSystem;
            _loc2_ = _loc1_.mixer;
            _loc3_ = _loc2_.volumeVideo * _loc2_.volumeMaster;
            if(this.volume != _loc3_)
            {
               this.volume = _loc3_;
               this.ns.soundTransform = new SoundTransform(this.volume,0);
            }
         }
      }
      
      override public function update(param1:int) : void
      {
         param1 = param1;
         this.checkMuteStatus();
      }
   }
}
