package game.gui.page
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpBitmap;
   import engine.landscape.travel.def.TravelDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.travel.view.TravelView;
   import engine.saga.Caravan;
   import engine.saga.ICaravan;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionType;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.Variable;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   import engine.scene.model.Scene;
   import engine.scene.model.SceneEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiCharacterIconSlot;
   import game.gui.travel.IGuiTravelTop;
   import game.gui.travel.IGuiTravelTopListener;
   import game.gui.travel.IGuiTravelTopToggle;
   import game.session.states.GameStateDataEnum;
   import game.session.states.HeroesState;
   import game.view.GamePageManagerAdapter;
   
   public class TravelPage extends GamePage implements IGuiTravelTopListener
   {
      
      public static var mcClazzTravelTopToggle:Class;
      
      public static var mcClazzTravelTops:Array = [];
       
      
      internal var guiTop:IGuiTravelTop;
      
      internal var guiToggle:IGuiTravelTopToggle;
      
      internal var scenePage:ScenePage;
      
      private var travelView:TravelView;
      
      private var talkie:TravelPageTalkies;
      
      private var scene:Scene;
      
      private var url:String;
      
      public var gp_l1:GuiGpBitmap;
      
      public var gp_r1:GuiGpBitmap;
      
      private var _saga:Saga;
      
      private var caravanVars:IVariableBag;
      
      private var initReady:Boolean;
      
      private var cmd_y:Cmd;
      
      private var tooltips:TravelPage_Tooltips;
      
      private var dayVar:Variable;
      
      private var _hideTravelHud:Boolean;
      
      public var appearanceIndex:int;
      
      private var _boundY:Boolean;
      
      private var _injury_location_check_countdown:int = 1000;
      
      private var _gpActivated:Boolean;
      
      private var gplayer:int;
      
      public function TravelPage(param1:GameConfig, param2:ScenePage)
      {
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1);
         this.cmd_y = new Cmd("cmd_travel_y",this.func_cmd_y);
         super(param1);
         allowPageScaling = false;
         this.scenePage = param2;
         this.travelView = param2.view.landscapeView.travelView;
         this.talkie = new TravelPageTalkies(this);
         this.scene = param2.scene;
         this.scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         this.url = this.scene._def.url;
         param1.pageManager.addEventListener(GamePageManagerAdapter.EVENT_POPPENING,this.poppeningHandler);
         addChild(this.gp_l1);
         addChild(this.gp_r1);
         this.gp_l1.visible = false;
         this.gp_r1.visible = false;
         this.tooltips = new TravelPage_Tooltips(this);
      }
      
      private function poppeningHandler(param1:Event) : void
      {
         this.checkHudEnables();
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         if(this.ready)
         {
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         }
         this.checkHudEnables();
      }
      
      override public function cleanup() : void
      {
         this.tooltips.cleanup();
         GpBinder.gpbinder.unbind(this.cmd_y);
         this.cmd_y.cleanup();
         this.cmd_y = null;
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
         if(this.cmd_y)
         {
            this.cmd_y.cleanup();
            this.cmd_y = null;
         }
         if(this.caravanVars)
         {
            this.caravanVars.removeEventListener(VariableEvent.TYPE,this.onTravelHudAppearanceUpdate);
            this.caravanVars = null;
         }
         if(this.saga)
         {
            this.saga.removeEventListener(SagaEvent.EVENT_HALT,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HUD_TRAVEL_ENABLED,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HUD_TRAVEL_HIDDEN,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HUD_CAMP_ENABLED,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HUD_MAP_ENABLED,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.sagaHudEnabledHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_INJURIES_CHANGED,this.sagaInjuriesChangedHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_HALTING,this.sagaHaltingHandler);
            this.saga = null;
         }
         config.pageManager.removeEventListener(GamePageManagerAdapter.EVENT_POPPENING,this.poppeningHandler);
         if(this.scene)
         {
            this.scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         }
         if(this.guiTop)
         {
            this.guiTop.cleanup();
            this.guiTop = null;
         }
         if(this.guiToggle)
         {
            this.guiToggle.cleanup();
            this.guiToggle = null;
         }
         this.travelView = null;
         this.scenePage = null;
         this.talkie.cleanup();
         this.talkie = null;
         config.context.appInfo.setSystemIdleKeepAwake(false);
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         config.context.appInfo.setSystemIdleKeepAwake(true);
         this.saga = config.saga;
         this.appearanceIndex = this.saga.getVarInt(SagaVar.VAR_TRAVEL_HUD_APPEARANCE);
         var _loc1_:Class = mcClazzTravelTops[this.appearanceIndex];
         this.specializedSetFullPageMovieClipClass(_loc1_);
      }
      
      protected function onTravelHudAppearanceUpdate(param1:VariableEvent) : void
      {
         var _loc2_:Variable = param1.value;
         if(_loc2_.def.name != SagaVar.VAR_TRAVEL_HUD_APPEARANCE)
         {
            return;
         }
         var _loc3_:int = _loc2_.asInteger;
         if(_loc3_ == this.appearanceIndex)
         {
            return;
         }
         if(_loc3_ < 0 || _loc3_ >= mcClazzTravelTops.length)
         {
            logger.error("ERROR: Invalid travel hud appearance set: " + _loc3_);
            return;
         }
         this.appearanceIndex = _loc3_;
         var _loc4_:Class = mcClazzTravelTops[this.appearanceIndex];
         this.specializedSetFullPageMovieClipClass(_loc4_);
         checkReady();
      }
      
      protected function specializedSetFullPageMovieClipClass(param1:Class, param2:Dictionary = null) : void
      {
         if(fullScreenMc)
         {
            removeChildFromContainer(fullScreenMc);
            if(fullScreenMc.parent == this)
            {
               removeChild(fullScreenMc);
            }
            fullScreenMc = null;
         }
         return setFullPageMovieClipClass(param1,param2);
      }
      
      private function sagaHudEnabledHandler(param1:Event) : void
      {
         this.checkHudEnables();
      }
      
      public function checkHudEnables() : void
      {
         if(!this.scenePage || !this.scene._def)
         {
            return;
         }
         var _loc1_:Boolean = this.ready;
         var _loc2_:Boolean = Boolean(this.saga) && Boolean(this.saga.def) && this.saga.hudCampEnabled;
         if(this.guiTop)
         {
            this.guiTop.campEnabled = _loc2_ && this.scene.landscape && Boolean(this.scene.landscape.travel) && !this.scene.landscape.travel.def.close;
            this.guiTop.guiEnabled = _loc1_ && Boolean(this.saga) && this.saga.hudTravelEnabled;
            this.guiTop.mapEnabled = Boolean(this.saga) && this.saga.hudMapEnabled;
            (this.guiTop as MovieClip).visible = Boolean(this.saga) && !this.saga.hudTravelHidden;
         }
         if(this.guiToggle)
         {
            this.guiToggle.guiEnabled = _loc1_;
            (this.guiToggle as MovieClip).visible = Boolean(this.saga) && !this.saga.hudTravelHidden;
         }
         var _loc3_:Boolean = _loc1_ && this.saga && this.saga.hudTravelEnabled && (this.saga.halted || this.saga.camped);
         this.gp_r1.visible = this.gp_l1.visible = _loc3_;
         this.checkTalkieInit();
         if(!this._boundY)
         {
            if(this.scene.ready)
            {
               if(Boolean(this.guiTop) && this.guiTop.movieClip.visible)
               {
                  this._boundY = true;
                  GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_y);
               }
            }
         }
         if(Boolean(this.guiTop) && _loc1_)
         {
            this.guiTop.extended = true;
         }
      }
      
      override protected function handleLoaded() : void
      {
         if(this.scene.cleanedup)
         {
            return;
         }
         if(fullScreenMc)
         {
            removeChildFromContainer(fullScreenMc);
            addChild(fullScreenMc);
            fullScreenMc.y = 0;
            this.guiTop = fullScreenMc as IGuiTravelTop;
            this.saga = config.saga;
            if(this.saga)
            {
               this.guiTop.init(config.gameGuiContext,this,this.saga);
            }
            if(mcClazzTravelTopToggle)
            {
               this.guiToggle = new mcClazzTravelTopToggle() as IGuiTravelTopToggle;
               this.guiToggle.init(config.gameGuiContext,this.guiTop,config.saga);
               config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.guiToggle as MovieClip,logger);
               addChild(this.guiToggle as MovieClip);
            }
            this.checkHudEnables();
            this.resizeHandler();
            this.doInitReady();
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc4_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc1_:Number = width;
         var _loc2_:Number = Math.max(height,640);
         if(PlatformInput.isTouch)
         {
            _loc1_ = Math.max(BoundedCamera.UI_AUTHOR_WIDTH * 1.2,width);
            _loc2_ = Math.max(BoundedCamera.UI_AUTHOR_HEIGHT * 1.2,height);
         }
         var _loc3_:Number = BoundedCamera.computeDpiScaling(_loc1_,_loc2_);
         _loc3_ = Math.min(2,_loc3_);
         if(this.guiTop)
         {
            _loc4_ = this.guiTop as MovieClip;
            _loc4_.x = width / 2;
            _loc4_.scaleX = _loc4_.scaleY = _loc3_;
            this.guiTop.resizeHandler();
         }
         if(this.guiToggle)
         {
            _loc5_ = this.guiToggle as MovieClip;
            _loc5_.x = width / 2;
            _loc5_.scaleX = _loc5_.scaleY = _loc3_;
            this.guiToggle.resizeHandler();
         }
         this.gp_l1.x = width / 2 - this.gp_l1.width;
         this.gp_l1.y = height - this.gp_l1.height;
         this.gp_r1.x = width / 2;
         this.gp_r1.y = height - this.gp_r1.height;
         if(this.talkie)
         {
            this.talkie.resizeHandler();
         }
      }
      
      public function get ready() : Boolean
      {
         if(this.scene.ready && !this.scenePage.wiping && !this.scene.paused && !this.saga.isProcessingActionTween)
         {
            if(!config.pageManager.poppening && !config.pageManager.war)
            {
               if(!this.saga || !this.saga.paused)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function guiTravelHeroes() : void
      {
         var _loc1_:Travel = null;
         var _loc2_:TravelLocator = null;
         if(!this.ready || !this.saga)
         {
            return;
         }
         if(this.scenePage.scene.landscape.travel)
         {
            _loc1_ = this.scenePage.scene.landscape.travel;
            _loc2_ = new TravelLocator().setup(_loc1_.def.id,null,_loc1_.position);
            config.fsm.current.data.setValue(GameStateDataEnum.TRAVEL_LOCATOR,_loc2_);
         }
         config.tutorialLayer.removeAllTooltips();
         config.fsm.transitionTo(HeroesState,config.fsm.current.data);
      }
      
      public function guiTravelMap() : void
      {
         if(!this.ready || !this.saga)
         {
            return;
         }
         logger.info("TravelPage.guiTravelMap");
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.CAMP_MAP;
         _loc1_.instant = false;
         _loc1_.restore_scene = true;
         this.saga.executeActionDef(_loc1_,null,null);
      }
      
      public function guiTravelTraining() : void
      {
         if(!this.ready || !this.saga)
         {
            return;
         }
         var _loc1_:Caravan = this.saga.caravan;
         if(!_loc1_)
         {
            return;
         }
         this.saga.performTraining();
      }
      
      public function guiTravelCamp() : void
      {
         if(!this.ready || !this.saga)
         {
            return;
         }
         logger.info("TravelPage.guiTravelCamp");
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.CAMP;
         _loc1_.instant = true;
         this.saga.executeActionDef(_loc1_,null,null);
      }
      
      public function guiTravelDecamp() : void
      {
         if(!this.ready || !this.saga)
         {
            return;
         }
         if(!this.saga.getVar(SagaVar.VAR_HUD_TRAVEL_ENABLED,VariableType.BOOLEAN))
         {
            return;
         }
         logger.info("TravelPage.guiTravelDecamp");
         var _loc1_:ActionDef = new ActionDef(null);
         _loc1_.type = ActionType.DECAMP;
         _loc1_.instant = true;
         this.saga.executeActionDef(_loc1_,null,null);
      }
      
      public function guiTravelOptions() : void
      {
         if(!this.ready || !this.saga)
         {
            return;
         }
         config.pageManager.showOptions();
      }
      
      public function doInitReady() : void
      {
         this.saga = config.saga;
         if(this.saga)
         {
            this.checkHudEnables();
         }
         this.initReady = true;
         this.checkTalkieInit();
         this._updateLandscapeInjuries();
         this.tooltips.startTooltips();
      }
      
      private function checkTalkieInit() : void
      {
         if(this.ready)
         {
            if(!this.talkie.initReady)
            {
               this.talkie.doInitReady();
            }
         }
         this.talkie.enableClick = this.ready;
      }
      
      override public function update(param1:int) : void
      {
         var _loc2_:TravelDef = null;
         super.update(param1);
         this.talkie.update(param1);
         if(this._injury_location_check_countdown > 0)
         {
            _loc2_ = Boolean(this.travelView) && Boolean(this.travelView.travel) ? this.travelView.travel.def : null;
            if(!_loc2_ || _loc2_.close)
            {
               this._injury_location_check_countdown = 0;
            }
            else if(this.saga && !this.saga.halted && !this.saga.camped && !this.saga.paused && (!this.saga.convo || this.saga.convo.finished))
            {
               if(this.saga.getVarBool(SagaVar.VAR_HUD_CAMP_ENABLED) && !this.saga.getVarBool(SagaVar.VAR_HUD_TRAVEL_HIDDEN))
               {
                  if(this.ready)
                  {
                     this._injury_location_check_countdown -= param1;
                     if(this._injury_location_check_countdown <= 0)
                     {
                        this._checkTravelInjuries();
                     }
                  }
               }
            }
         }
      }
      
      public function handleLandscapeClick(param1:String) : Boolean
      {
         switch(param1)
         {
            case "click_heroes":
               this.guiTravelHeroes();
               break;
            case "click_market":
               this.saga.showSagaMarket();
               break;
            case "click_leave":
               this.guiTravelDecamp();
               break;
            case "click_map":
               this.guiTravelMap();
               break;
            case "click_training":
               this.guiTravelTraining();
               break;
            case "click_rest":
               if(this.ready && Boolean(this.saga))
               {
                  this.saga.restOneDay();
                  this.tooltips.onRest();
               }
               break;
            default:
               return false;
         }
         return true;
      }
      
      private function sagaInjuriesChangedHandler(param1:Event) : void
      {
         this._updateLandscapeInjuries();
      }
      
      private function _updateLandscapeInjuries() : void
      {
         var _loc1_:Caravan = null;
         var _loc2_:IEntityListDef = null;
         if(this.saga)
         {
            _loc1_ = this.saga.caravan;
            if(_loc1_ && this.scenePage && Boolean(this.scenePage.view))
            {
               _loc2_ = _loc1_.legend.roster;
               this.scenePage.view.landscapeView.hasInjuries = _loc2_.hasInjuredCombatants;
            }
         }
      }
      
      private function _checkTravelInjuries() : void
      {
         if(!this.saga)
         {
            return;
         }
         var _loc1_:int = this.saga.getVarInt(SagaVar.VAR_TIP_TRAVEL_INJURY_REMAINING);
         if(_loc1_ <= 0)
         {
            return;
         }
         var _loc2_:int = this.saga.getVarInt(SagaVar.VAR_PLAY_MINUTES);
         var _loc3_:int = this.saga.getVarInt(SagaVar.VAR_TIP_TRAVEL_INJURY_NEXT_TIME);
         if(_loc3_ > _loc2_)
         {
            return;
         }
         var _loc4_:Caravan = this.saga.caravan;
         if(!_loc4_ || !this.scenePage || !this.scenePage.view)
         {
            return;
         }
         if(!_loc4_.leader)
         {
            return;
         }
         var _loc5_:IEntityDef = this.saga.def.cast.getEntityDefById(_loc4_.leader);
         if(!_loc5_)
         {
            return;
         }
         var _loc6_:IEntityListDef = _loc4_.legend.roster;
         var _loc7_:Boolean = _loc6_.hasInjuredCombatants;
         if(!_loc7_)
         {
            return;
         }
         _loc1_--;
         this.saga.setVar(SagaVar.VAR_TIP_TRAVEL_INJURY_REMAINING,_loc1_);
         if(_loc1_ > 0)
         {
            _loc3_ = _loc2_ + 30;
            this.saga.setVar(SagaVar.VAR_TIP_TRAVEL_INJURY_NEXT_TIME,_loc3_);
         }
         var _loc8_:String = config.context.locale.translateGui("tip_travel_injury");
         this.saga.performSpeak(null,_loc5_,_loc8_,5,null,null,false);
      }
      
      private function func_cmd_y(param1:CmdExec) : void
      {
         if(!this.saga)
         {
            return;
         }
         if(this.saga.halting)
         {
            if(!this.saga.halted && !this.saga.camped)
            {
               logger.info("Ignoring TravelPage func_cmd_y due to saga.halting count=" + this.saga.haltingCount);
               return;
            }
         }
         this._gpToggle();
      }
      
      private function _gpToggle() : void
      {
         if(!this._gpActivated)
         {
            this._gpActivate();
         }
         else
         {
            this._gpDeactivate();
         }
      }
      
      private function _gpActivate() : void
      {
         GpBinder.gpbinder.unbind(this.cmd_y);
         this.gplayer = GpBinder.gpbinder.createLayer("TravelPage");
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_y);
         this._gpActivated = true;
         PlatformInput.dispatcher.dispatchEvent(new Event(PlatformInput.EVENT_CURSOR_LOST_FOCUS));
         if(this.guiTop)
         {
            this.guiTop.activateGp();
         }
         if(this.guiToggle)
         {
            this.guiToggle.activateGp();
         }
      }
      
      private function _gpDeactivate() : void
      {
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         this._gpActivated = false;
         if(this.guiTop)
         {
            this.guiTop.deactivateGp();
         }
         if(this.guiToggle)
         {
            this.guiToggle.deactivateGp();
         }
      }
      
      private function sagaHaltingHandler(param1:Event) : void
      {
         this._gpDeactivate();
      }
      
      public function gpPointerHandler() : void
      {
         if(this.talkie)
         {
            this.talkie.gpPointerHandler();
         }
      }
      
      public function talkieNextPrev(param1:IGuiCharacterIconSlot, param2:Point, param3:Boolean) : IGuiCharacterIconSlot
      {
         if(this.talkie)
         {
            return this.talkie.talkieNextPrev(param1,param2,param3);
         }
         return null;
      }
      
      override public function handleOptionsButton() : void
      {
         if(this.guiTop)
         {
            this.guiTop.handleOptionsButton();
         }
      }
      
      public function set hideTravelHud(param1:Boolean) : void
      {
         this._hideTravelHud = param1;
         if(this.guiTop)
         {
            this.guiTop.movieClip.visible = !param1;
         }
         if(this.guiToggle)
         {
            (this.guiToggle as MovieClip).visible = !param1;
         }
      }
      
      public function get hideTravelHud() : Boolean
      {
         return this._hideTravelHud;
      }
      
      public function getGuiTop() : IGuiTravelTop
      {
         return this.guiTop;
      }
      
      public function removeGuiTop() : IGuiTravelTop
      {
         var _loc1_:IGuiTravelTop = this.guiTop;
         var _loc2_:DisplayObject = this.guiTop as DisplayObject;
         if(_loc2_)
         {
            removeChild(_loc2_);
         }
         if(fullScreenMc == this.guiTop)
         {
            fullScreenMc = null;
         }
         this.guiTop = null;
         return _loc1_;
      }
      
      public function removeToggle() : void
      {
      }
      
      private function get saga() : Saga
      {
         return this._saga;
      }
      
      private function set saga(param1:Saga) : void
      {
         var _loc2_:ICaravan = null;
         if(this._saga)
         {
            if(this.caravanVars)
            {
               this.caravanVars.removeEventListener(VariableEvent.TYPE,this.onTravelHudAppearanceUpdate);
               this.caravanVars = null;
            }
            this._saga.removeEventListener(SagaEvent.EVENT_HALT,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_HUD_TRAVEL_ENABLED,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_HUD_TRAVEL_HIDDEN,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_HUD_CAMP_ENABLED,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_HUD_MAP_ENABLED,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.sagaHudEnabledHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_INJURIES_CHANGED,this.sagaInjuriesChangedHandler);
            this._saga.removeEventListener(SagaEvent.EVENT_HALTING,this.sagaHaltingHandler);
            this._saga = null;
         }
         this._saga = param1;
         if(this._saga)
         {
            _loc2_ = this.saga.icaravan;
            this.caravanVars = !!_loc2_ ? _loc2_.vars : null;
            if(this.caravanVars)
            {
               this.caravanVars.addEventListener(VariableEvent.TYPE,this.onTravelHudAppearanceUpdate);
            }
            this._saga.addEventListener(SagaEvent.EVENT_HALT,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_HUD_TRAVEL_ENABLED,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_HUD_TRAVEL_HIDDEN,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_HUD_CAMP_ENABLED,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_HUD_MAP_ENABLED,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_PAUSE,this.sagaHudEnabledHandler);
            this._saga.addEventListener(SagaEvent.EVENT_INJURIES_CHANGED,this.sagaInjuriesChangedHandler);
            this._saga.addEventListener(SagaEvent.EVENT_HALTING,this.sagaHaltingHandler);
         }
      }
   }
}
