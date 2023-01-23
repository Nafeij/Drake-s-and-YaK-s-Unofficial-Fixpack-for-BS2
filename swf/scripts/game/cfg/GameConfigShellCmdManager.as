package game.cfg
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformFlash;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.anim.view.AnimController;
   import engine.battle.Fastall;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.op.model.Op_SpawnUnit;
   import engine.battle.ability.effect.op.model.Op_TargetAoe;
   import engine.battle.ability.effect.op.model.Op_WaitForActionComplete;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.view.EntityView;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.aimodule.AiGlobalConfig;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpSource;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.util.AppInfo;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.entity.def.EntityDef;
   import engine.entity.def.ItemDef;
   import engine.gui.GuiUtil;
   import engine.gui.IGuiButton;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.view.ClickablePair;
   import engine.landscape.view.ILandscapeView;
   import engine.resource.Resource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.VideoParams;
   import engine.saga.action.Action_Battle;
   import engine.scene.model.Scene;
   import engine.scene.view.SceneMouseAdapter;
   import engine.scene.view.SceneViewSprite;
   import engine.session.Alert;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import engine.subtitle.SubtitleSequenceResource;
   import engine.tile.def.TileLocation;
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import game.entry.GameEntry;
   import game.gui.page.ScenePage;
   import game.gui.page.VideoPage;
   import game.session.states.GameStateDataEnum;
   import game.session.states.SceneState;
   import game.session.states.VideoQueueState;
   import game.session.states.VideoTutorial1State;
   import game.session.states.VideoTutorial2State;
   import game.session.states.tutorial.TutorialEndState;
   import game.view.TutorialLayer;
   import starling.textures.Texture;
   
   public class GameConfigShellCmdManager extends ShellCmdManager
   {
       
      
      public var config:GameConfig;
      
      public var btlmusic:BattleMusicShellCmdManager;
      
      public var animShell:AnimShellCmdManager;
      
      public var bundleShell:BundleShellCmdManager;
      
      public var convoShell:ConvoShellCmdManager;
      
      public var gaShell:GaShellCmdManager;
      
      public var soundShell:SoundShellCmdManager;
      
      private var _debugMouse:Boolean;
      
      private var _debugMouseObjects:Vector.<InteractiveObject>;
      
      public function GameConfigShellCmdManager(param1:GameConfig)
      {
         this._debugMouseObjects = new Vector.<InteractiveObject>();
         super(param1.logger,true);
         this.config = param1;
         this.addShellCmds();
      }
      
      public static function performResourceCheck(param1:String, param2:GameConfig) : void
      {
         var _loc5_:ByteArray = null;
         var _loc6_:String = null;
         var _loc3_:ILogger = param2.logger;
         var _loc4_:String = param2.resman.report(param1);
         if(_loc4_)
         {
            _loc5_ = new ByteArray();
            _loc5_.writeUTFBytes(_loc4_);
            _loc6_ = "resources_tab.txt";
            param2.context.appInfo.saveFile(AppInfo.DIR_DOCUMENTS,_loc6_,_loc5_,false);
            _loc3_.info("Resources TAB file saved to Documents " + _loc6_ + " and copied to clipboard");
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,_loc4_);
         }
      }
      
      public function addShellCmds() : void
      {
         this.add("developer",this.shellFuncDeveloper);
         this.add("redraw_regions",this.shellFuncRedrawRegions);
         this.add("resources",this.shellFuncResources);
         this.add("resources_loadtimes",this.shellFuncResourcesLoadTimes);
         this.add("quality_stage",this.shellFuncQuality);
         this.add("heraldry",this.shellFuncHeraldry);
         this.add("perf",this.shellFuncPerf);
         this.add("fps_cap",this.shellFuncFpsCap);
         this.add("quality_graphics",this.shellFuncGraphicsQuality);
         this.add("quality_texture",this.shellFuncTextureQuality);
         this.add("dispose_context3d",this.shellFuncDisposeContext3d);
         this.add("display_list",this.shellFuncDisplayList);
         this.add("platform_info",this.shellFuncPlatformInfo);
         this.add("gp_debug",this.shellFuncGpDebug);
         this.add("gp_binder_dump",this.shellFuncGpBinderDump);
         this.add("kb_binder_dump",this.shellFuncKbBinderDump);
         this.add("selfpopup_debug",this.shellFuncSelfPopupDebug);
         this.add("alias",this.shellFuncAlias);
         this.add("debug_mouse",this.shellFuncDebugMouse);
         this.add("debug_mrcontinue",this.shellFuncDebugMrContinue);
         this.add("textscale",this.shellFuncTextScale);
         this.add("click_tooltip_follow",this.shellFuncClickTooltipFollow);
         this.addAlias("battle","fsm state battle");
         if(this.config.options.developer)
         {
            this.add("log_anim_events",this.shellFuncLogAnimEvents);
            this.add("alert",this.shellFuncAlert);
            this.add("video_play",this.shellFuncVideoPlay);
            this.add("video_config",this.shellFuncVideoConfig);
            this.add("end_tutorial",this.shellFuncEndTutorial);
            this.add("fly",this.shellFuncFly);
            this.add("spawnadd",this.shellFuncSpawnadd,true);
            this.add("items",this.shellFuncItems);
            this.add("items_html",this.shellFuncItemsHtml);
            this.add("items_unlock",this.shellFuncItemsUnlock,true);
            this.add("landscape_view_layers",this.shellFuncLandscapeViewLayers);
            this.add("subtitle_show",this.shellFuncSubtitleShow);
            this.add("subtitle_hide",this.shellFuncSubtitleHide);
            this.add("subtitle_load",this.shellFuncSubtitleLoad);
            this.add("debug_ai",this.shellFuncAiDebug);
            this.add("debug_target_aoe",this.shellFuncDebugTargetAoe);
            this.add("debug_rtf",this.shellFuncRtfDebug);
            this.add("debug_resources",this.shellFuncResourcesDebug);
            this.add("tilt",this.shellFuncTilt);
            this.add("portrait",this.shellFuncPortrait);
            this.add("ai",this.shellFuncAi,true);
            this.add("ai_player",this.shellFuncAiPlayer,true);
            this.add("fastall",this.shellFuncFastall,true);
            this.add("quickload",this.shellFuncQuickload);
            this.add("invis_show",this.shellFuncInvisShow,true);
            this.add("weather",this.shellFuncWeather);
            this.add("textures",this.shellFuncTextures);
            this.add("frame_throttle",this.shellCmdFuncThrottleFrames);
            this.add("debug_text_border",this.shellFuncToggleScaledTextFieldBorders);
            this.btlmusic = new BattleMusicShellCmdManager(this.config);
            this.addShell("btlmusic",this.btlmusic);
            this.animShell = new AnimShellCmdManager(this.config);
            this.addShell("anim",this.animShell);
            this.bundleShell = new BundleShellCmdManager(this.config);
            this.addShell("bundle",this.bundleShell);
            this.convoShell = new ConvoShellCmdManager(this.config);
            this.addShell("convo",this.convoShell);
            this.soundShell = new SoundShellCmdManager(this.config);
            this.addShell("sound",this.soundShell);
         }
         this.gaShell = new GaShellCmdManager(this.config);
         this.addShell("ga",this.gaShell);
      }
      
      private function shellFuncDebugTargetAoe(param1:CmdExec) : void
      {
         Op_TargetAoe.DEBUG_TARGET_AOE = !Op_TargetAoe.DEBUG_TARGET_AOE;
         logger.info("Op_TargetAoe.DEBUG_TARGET_AOE=" + Op_TargetAoe.DEBUG_TARGET_AOE);
      }
      
      private function shellFuncAiDebug(param1:CmdExec) : void
      {
         AiGlobalConfig.DEBUG = !AiGlobalConfig.DEBUG;
         logger.info("AiConfig.DEBUG_AI=" + AiGlobalConfig.DEBUG);
      }
      
      private function shellFuncDeveloper(param1:CmdExec) : void
      {
         this.config.options.developer = !this.config.options.developer;
         logger.info("developer=" + this.config.options.developer);
      }
      
      private function shellFuncResourcesLoadTimes(param1:CmdExec) : void
      {
         Resource.reportGlobalResourceTiming(logger);
      }
      
      private function shellFuncResources(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = param1.param;
         if(_loc3_.length > 1)
         {
            _loc2_ = _loc3_[1];
         }
         performResourceCheck(_loc2_,this.config);
      }
      
      private function shellFuncHeraldry(param1:CmdExec) : void
      {
         this.config.pageManager.sagaHeraldry.showSagaHeraldry(true);
      }
      
      private function shellFuncQuality(param1:CmdExec) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            _loc3_ = _loc2_[1];
            this.config.pageManager.holder.stage.quality = _loc3_;
         }
         logger.info("stage quality=" + this.config.pageManager.holder.stage.quality);
      }
      
      private function shellFuncRedrawRegions(param1:CmdExec) : void
      {
         var _loc3_:uint = 0;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            this.config.context.appInfo.hideRedrawRegions();
         }
         else
         {
            _loc3_ = uint(_loc2_[1]);
            this.config.context.appInfo.showRedrawRegions(_loc3_);
         }
      }
      
      private function shellFuncDisposeContext3d(param1:CmdExec) : void
      {
         if(this.config.keybinder)
         {
            this.config.keybinder.func_dispose_context3d(null);
         }
      }
      
      private function shellFuncTextScale(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            Platform.setTextScale(_loc2_[1]);
         }
         logger.info("Platform.textScale: " + Platform.textScale);
      }
      
      private function shellFuncClickTooltipFollow(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            ClickablePair.ALLOW_FOLLOW_MOUSE = BooleanVars.parse(_loc2_[1]);
         }
         logger.info("ClickablePair.ALLOW_FOLLOW_MOUSE: " + ClickablePair.ALLOW_FOLLOW_MOUSE);
      }
      
      private function shellFuncTextureQuality(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            Platform.qualityTextures = _loc2_[1];
         }
         logger.info("Platform.graphicsQuality: " + Platform.qualityTextures);
      }
      
      private function shellFuncGraphicsQuality(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length >= 2)
         {
            Platform.drawQuality = _loc2_[1];
         }
         logger.info("Platform.drawQuality: " + Platform.drawQuality);
      }
      
      private function shellFuncLogAnimEvents(param1:CmdExec) : void
      {
         AnimController.log_anim_events = !AnimController.log_anim_events;
         logger.info("log_anim_events " + AnimController.log_anim_events);
      }
      
      private function shellFuncAlert(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:AlertOrientationType = Enum.parse(AlertOrientationType,_loc2_[1]) as AlertOrientationType;
         var _loc4_:AlertStyleType = Enum.parse(AlertStyleType,_loc2_[2]) as AlertStyleType;
         var _loc5_:String = _loc2_[3];
         var _loc6_:String = _loc2_[4];
         var _loc7_:String = _loc2_.length > 4 ? _loc2_[5] : "Proving Grounds";
         var _loc8_:String = _loc2_.length > 5 ? _loc2_[6] : null;
         var _loc9_:Alert = Alert.create(0,_loc5_,_loc6_,_loc7_,_loc8_,_loc3_,_loc4_,null);
         this.config.alerts.addAlert(_loc9_);
      }
      
      private function shellFuncVideoPlay(param1:CmdExec) : void
      {
         var _loc2_:VideoParams = new VideoParams().setUrl(param1.param[1]).setSubtitle(param1.param[2]);
         this.config.fsm.current.data.setValue(GameStateDataEnum.VIDEO_PARAMS,_loc2_);
         this.config.fsm.transitionTo(VideoQueueState,this.config.fsm.current.data);
      }
      
      private function shellFuncVideoConfig(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 7)
         {
            logger.info("Usage: <min width> <min height> <max width> <max height> <vid width> <vid height> <cinemascope>");
         }
         VideoPage.VIDEO_FIT.setupMax(_loc2_[1],_loc2_[2]);
         VideoPage.VIDEO_FIT.setupMax(_loc2_[3],_loc2_[4]);
         VideoPage.VIDEO_WIDTH = _loc2_[5];
         VideoPage.VIDEO_HEIGHT = _loc2_[6];
         VideoPage.CINEMASCOPE = BooleanVars.parse(_loc2_[7]);
      }
      
      private function shellFuncVtut1(param1:CmdExec) : void
      {
         this.config.fsm.transitionTo(VideoTutorial1State,this.config.fsm.current.data);
      }
      
      private function shellFuncVtut2(param1:CmdExec) : void
      {
         this.config.fsm.transitionTo(VideoTutorial2State,this.config.fsm.current.data);
      }
      
      private function shellFuncEndTutorial(param1:CmdExec) : void
      {
         if(this.config.accountInfo.tutorial)
         {
            this.config.fsm.transitionTo(TutorialEndState,this.config.fsm.current.data);
         }
      }
      
      private function shellFuncRtfDebug(param1:CmdExec) : void
      {
         Op_WaitForActionComplete.DEBUG_WAIT = !Op_WaitForActionComplete.DEBUG_WAIT;
         logger.isDebugEnabled = true;
         logger.info("Op_WaitForActionComplete.DEBUG_WAIT " + Op_WaitForActionComplete.DEBUG_WAIT);
      }
      
      private function shellFuncResourcesDebug(param1:CmdExec) : void
      {
         Resource.DEBUG_RESOURCES = !Resource.DEBUG_RESOURCES;
         logger.isDebugEnabled = true;
         logger.info("Resource.DEBUG_RESOURCES " + Resource.DEBUG_RESOURCES);
      }
      
      private function shellFuncGpDebug(param1:CmdExec) : void
      {
         GpSource.GP_DEBUG = !GpSource.GP_DEBUG;
         logger.info("GpSource.GP_DEBUG=" + GpSource.GP_DEBUG);
      }
      
      private function shellFuncGpBinderDump(param1:CmdExec) : void
      {
         logger.info(GpBinder.gpbinder.getDebugDump());
      }
      
      private function shellFuncKbBinderDump(param1:CmdExec) : void
      {
         this.config.keybinder.getDebugDump(logger);
      }
      
      private function shellFuncSelfPopupDebug(param1:CmdExec) : void
      {
         var _loc2_:String = " _____ SELF POPUP DEBUG _____\n";
         var _loc3_:ScenePage = this.config.pageManager.currentPage as ScenePage;
         if(_loc3_)
         {
            _loc2_ += _loc3_.battleHandler.hud.popupSelfHelper.getDebugString();
         }
         logger.info(_loc2_);
      }
      
      private function shellFuncPlatformInfo(param1:CmdExec) : void
      {
         Platform.getInfo(logger);
         PlatformFlash.getInfo(logger);
         PlatformStarling.getInfo(logger);
      }
      
      private function shellFuncDebugMrContinue(param1:CmdExec) : void
      {
         var _loc7_:Boolean = false;
         var _loc2_:String = "ScenePage|MatchResolutionPage|container|match_resolution|button$continue";
         var _loc3_:DisplayObject = this.config.pageManager.holder;
         var _loc4_:Object = TutorialLayer.findRootObject(_loc3_,_loc2_,logger,true) as Object;
         var _loc5_:IGuiButton = !!_loc4_ ? _loc4_.object as IGuiButton : null;
         if(!_loc5_)
         {
            logger.error(" no such button");
            return;
         }
         logger.info("Resetting listeners on " + this.constructFullPath(_loc5_.movieClip));
         _loc5_.resetListeners();
         var _loc6_:DisplayObjectContainer = _loc5_.movieClip.parent;
         while(_loc6_)
         {
            _loc7_ = true;
            if(!_loc6_.mouseChildren)
            {
               logger.error("Found mouse-blocker     : " + this.constructFullPath(_loc6_));
               _loc6_.mouseChildren = true;
               _loc7_ = false;
            }
            if(!_loc6_.mouseEnabled)
            {
               logger.info("Found mouse-questionable : " + this.constructFullPath(_loc6_));
               _loc6_.mouseEnabled = true;
               _loc7_ = false;
            }
            if(_loc7_)
            {
               logger.info("                      OK : " + this.constructFullPath(_loc6_));
            }
            _loc6_ = _loc6_.parent;
         }
      }
      
      private function shellFuncDebugMouse(param1:CmdExec) : void
      {
         var _loc2_:InteractiveObject = null;
         if(this._debugMouse)
         {
            this._debugMouse = false;
            for each(_loc2_ in this._debugMouseObjects)
            {
               _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.debugMouseDownHandler);
            }
            logger.info("Debug mouse disabled");
            return;
         }
         this._debugMouse = true;
         TutorialLayer.printDisplayListStatic(this.config.pageManager.holder,"",0,logger,true);
         PlatformStarling.getInfo(logger);
         this.debugMouseAttachAll(PlatformFlash.stage);
      }
      
      private function debugMouseAttachAll(param1:DisplayObject) : void
      {
         var _loc4_:int = 0;
         var _loc5_:DisplayObject = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:InteractiveObject = param1 as InteractiveObject;
         if(_loc2_)
         {
            _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.debugMouseDownHandler);
            this._debugMouseObjects.push(_loc2_);
         }
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               _loc5_ = _loc3_.getChildAt(_loc4_);
               this.debugMouseAttachAll(_loc5_);
               _loc4_++;
            }
         }
      }
      
      private function constructFullPath(param1:DisplayObject) : String
      {
         var _loc2_:String = "";
         while(param1)
         {
            if(_loc2_)
            {
               _loc2_ = param1.name + "|" + _loc2_;
            }
            else
            {
               _loc2_ = param1.name;
            }
            param1 = param1.parent;
         }
         return _loc2_;
      }
      
      private function debugMouseDownHandler(param1:MouseEvent) : void
      {
         logger.info("DEBUG MOUSE: " + param1);
         var _loc2_:String = this.constructFullPath(param1.target as DisplayObject);
         var _loc3_:String = this.constructFullPath(param1.currentTarget as DisplayObject);
         logger.info("          t: " + _loc2_);
         logger.info("         ct: " + _loc3_);
      }
      
      private function shellFuncDisplayList(param1:CmdExec) : void
      {
         var _loc2_:String = param1.param[1];
         var _loc3_:int = int(param1.param[2]);
         TutorialLayer.printDisplayListStatic(this.config.pageManager.holder,_loc2_,_loc3_,logger,false);
      }
      
      private function shellFuncAlias(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Array = null;
         var _loc6_:* = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc3_:Array = param1.param;
         if(_loc3_.length == 1)
         {
            _loc5_ = [];
            for(_loc6_ in _aliases)
            {
               _loc7_ = _aliases[_loc6_];
               if(_loc7_)
               {
                  _loc5_.push({
                     "key":_loc6_,
                     "value":_loc7_
                  });
               }
            }
            if(_loc5_.length)
            {
               _loc5_.sortOn("key");
               logger.info("Aliases:");
               logger.info("------------------");
               for each(_loc8_ in _loc5_)
               {
                  _loc6_ = _loc8_.key;
                  _loc7_ = _loc8_.value;
                  logger.info("    " + StringUtil.padRight(_loc6_," ",20) + " " + _loc7_);
               }
               logger.info("------------------");
            }
            else
            {
               logger.info("No aliases defined");
            }
            logger.info("Usage: alias [-]<alias name> [alias value]");
            return;
         }
         _loc6_ = _loc3_[1];
         _loc6_ = _loc6_.toLowerCase();
         if(Boolean(_loc6_) && _loc6_.charAt(0) == "-")
         {
            _loc4_ = true;
            _loc6_ = _loc6_.substr(1);
         }
         _loc7_ = getAlias(_loc6_);
         if(_loc3_.length == 2)
         {
            if(!_loc7_)
            {
               logger.error("No such alias [" + _loc6_ + "]");
               return;
            }
            if(_loc4_)
            {
               removeAlias(_loc6_);
               logger.info("Deleted alias [" + _loc6_ + "] " + _loc7_);
               removeAlias(_loc6_);
               return;
            }
            logger.info("Alias [" + _loc6_ + "] " + _loc7_);
            return;
         }
         _loc3_.shift();
         _loc3_.shift();
         _loc7_ = _loc3_.join(" ");
         addAlias(_loc6_,_loc7_);
         logger.info("Alias [" + _loc6_ + "] " + _loc7_);
      }
      
      private function shellFuncPortrait(param1:CmdExec) : void
      {
         this.config.context.appInfo.setAspectRatio("any");
      }
      
      private function shellFuncAi(param1:CmdExec) : void
      {
         BattleFsmConfig.globalEnableAi = !BattleFsmConfig.globalEnableAi;
         logger.info("BattleFsmConfig.globalEnableAi=" + BattleFsmConfig.globalEnableAi);
      }
      
      private function shellFuncAiPlayer(param1:CmdExec) : void
      {
         BattleFsmConfig.globalPlayerAi = !BattleFsmConfig.globalPlayerAi;
         logger.info("BattleFsmConfig.globalPlayerAi=" + BattleFsmConfig.globalPlayerAi);
      }
      
      private function shellFuncTilt(param1:CmdExec) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:BoundedCamera = SceneMouseAdapter.instanceCamera;
         if(!param1)
         {
            logger.info("No scene camera");
            return;
         }
         var _loc3_:Array = param1.param;
         if(_loc3_.length >= 3)
         {
            _loc4_ = Number(_loc3_[1]);
            _loc5_ = Number(_loc3_[2]);
            _loc2_.setTiltOffset(_loc4_,_loc5_);
         }
         logger.info("tilt= " + _loc2_._tiltOffset + " actual=" + _loc2_.actualTiltOffset);
      }
      
      private function shellFuncItems(param1:CmdExec) : void
      {
         if(this.config.itemDefs)
         {
            this.config.itemDefs.printItemDefs(logger);
         }
      }
      
      private function shellFuncItemsHtml(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc3_:ByteArray = null;
         if(this.config.itemDefs)
         {
            _loc2_ = this.config.itemDefs.makeItemDefsHtmlTable();
            _loc3_ = new ByteArray();
            _loc3_.writeUTFBytes(_loc2_);
            this.config.context.appInfo.saveFile(null,"debug/items.html",_loc3_,false);
         }
      }
      
      private function shellFuncItemsUnlock(param1:CmdExec) : void
      {
         ItemDef.unlockAll = !ItemDef.unlockAll;
         logger.info("ItemDef.unlockAll=" + ItemDef.unlockAll);
      }
      
      private function shellFuncSpawnadd(param1:CmdExec) : void
      {
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         var _loc3_:EntityDef = this.config.saga.def.cast.getEntityDefById("dredge_grunt_b") as EntityDef;
         var _loc4_:TileLocation = Op_SpawnUnit.getEdgeLocation(_loc2_.scene.focusedBoard,_loc3_,null,logger);
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:TileLocation = TileLocation.fetch(0,0);
         var _loc6_:BattleFacing = BattleFacing.findFacing(_loc5_.x - _loc4_.x,_loc5_.y - _loc4_.y);
         var _loc7_:BattleEntity = _loc2_.scene.focusedBoard.addPartyMember("npc",null,"npc","npc",null,_loc3_,BattlePartyType.AI,0,false,_loc6_,_loc4_,true) as BattleEntity;
         _loc7_.deploymentReady = true;
         var _loc8_:BattleFsm = _loc2_.battleHandler.fsm;
         _loc8_.order.addEntity(_loc7_);
      }
      
      private function shellFuncFly(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_.length > 1 ? _loc2_[1] : null;
         var _loc4_:uint = _loc2_.length > 2 ? uint(_loc2_[2]) : 16755370;
         if(!_loc3_)
         {
            _loc3_ = "Regular <font color=\'#00ff00\'>Green</font>";
         }
         this.config.flyManager.showScreenFlyText(_loc3_,_loc4_,"ui_dying_peasants",0);
      }
      
      private function shellFuncLandscapeViewLayers(param1:CmdExec) : void
      {
         var _loc5_:ILandscapeView = null;
         var _loc6_:LandscapeLayerDef = null;
         var _loc2_:SceneState = this.config.fsm.current as SceneState;
         var _loc3_:SceneViewSprite = !!_loc2_ ? _loc2_.loader.viewSprite : null;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:int = 0;
         for each(_loc5_ in _loc3_._landscapeViews)
         {
            if(_loc3_._landscapeViews.length > 0)
            {
               if(_loc3_.landscapeIndex == _loc4_)
               {
                  logger.info("Landscape " + _loc4_ + "(ACTIVE)");
               }
               else
               {
                  logger.info("Landscape " + _loc4_);
               }
               _loc4_++;
            }
            for each(_loc6_ in _loc5_.selectedLayerDefs)
            {
               if(_loc5_.hasLayerSprite(_loc6_.nameId))
               {
                  logger.info("    " + StringUtil.padRight(_loc6_.nameId," ",20) + " @ " + _loc6_.speed.toFixed(2) + " sprite count " + _loc6_.layerSprites.length);
               }
            }
         }
      }
      
      private function shellFuncSubtitleShow(param1:CmdExec) : void
      {
         this.config.pageManager.subtitle.showSubtitle(param1.cmdline);
      }
      
      private function shellFuncSubtitleHide(param1:CmdExec) : void
      {
         this.config.pageManager.subtitle.hideSubtitle();
      }
      
      private function shellFuncSubtitleLoad(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_[1];
         var _loc4_:SubtitleSequenceResource = this.config.resman.getResource(_loc3_,SubtitleSequenceResource) as SubtitleSequenceResource;
         _loc4_.addResourceListener(this.subtitleSequenceResourceHandler);
      }
      
      private function shellFuncFpsCap(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:String = _loc2_.length > 1 ? _loc2_[1] : null;
         if(_loc3_)
         {
            this.config.context.appInfo.root.stage.frameRate = Number(_loc3_);
         }
         logger.info("Stage framerate: " + this.config.context.appInfo.root.stage.frameRate);
      }
      
      private function shellCmdFuncThrottleFrames(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         var _loc3_:int = _loc2_.length > 1 ? int(_loc2_[1]) : 0;
         GameEntry.FRAMETIME_THROTTLE_MS = _loc3_;
      }
      
      private function shellFuncPerf(param1:CmdExec) : void
      {
         this.config.dispatchEvent(new Event(GameConfig.EVENT_TOGGLE_PERF));
      }
      
      private function subtitleSequenceResourceHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:SubtitleSequenceResource = param1.resource as SubtitleSequenceResource;
         this.config.ccs.subtitle.sequence = _loc2_.sequence;
         _loc2_.removeResourceListener(this.subtitleSequenceResourceHandler);
         _loc2_.release();
      }
      
      private function shellFuncQuickload(param1:CmdExec) : void
      {
         var _loc2_:* = !ScenePage.DISABLE_WIPEIN;
         ScenePage.DISABLE_WIPEIN = _loc2_;
         Scene.DISABLE_BATTLEPAN = _loc2_;
         Action_Battle.FINISH_SAGA_DELAY = _loc2_ ? 1 : 3;
         logger.info("Quickload " + _loc2_);
      }
      
      private function shellFuncFastall(param1:CmdExec) : void
      {
         Fastall.fastall = !Fastall.fastall;
         logger.info("Fastall " + Fastall.fastall);
      }
      
      private function shellFuncInvisShow(param1:CmdExec) : void
      {
         var _loc3_:EntityView = null;
         EntityView.INVISIBLE_SHOW = !EntityView.INVISIBLE_SHOW;
         var _loc2_:BattleBoardView = BattleBoardView.instance;
         for each(_loc3_ in _loc2_.entityViews)
         {
            _loc3_.entityVisibleHandler(null);
         }
      }
      
      private function shellFuncTextures(param1:CmdExec) : void
      {
         logger.info(Texture.debugDump());
      }
      
      private function shellFuncWeather(param1:CmdExec) : void
      {
         this.exec("page current view landscape " + param1.cmdline);
      }
      
      private function shellFuncToggleScaledTextFieldBorders(param1:CmdExec) : void
      {
         GuiUtil.SHOW_TEXTFIELD_BORDERS = !GuiUtil.SHOW_TEXTFIELD_BORDERS;
      }
      
      public function update() : void
      {
         if(this.btlmusic)
         {
            this.btlmusic.update();
         }
      }
   }
}
