package game.gui.page
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.PlatformStarling;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevBinder;
   import engine.core.locale.LocaleCategory;
   import engine.core.render.BoundedCamera;
   import engine.core.util.StringUtil;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.landscape.def.LandscapeSplineDef;
   import engine.landscape.def.LandscapeSplinePoint;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import engine.math.MathUtil;
   import engine.resource.BitmapResource;
   import engine.saga.CaravanDef;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.scene.model.SceneEvent;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.GuiIconStarling;
   import game.gui.travel.IGuiMapCamp;
   import game.gui.travel.IGuiMapCampListener;
   import game.view.GamePageManagerAdapter;
   
   public class MapCampPage extends ScenePage implements IGuiMapCampListener
   {
      
      public static var DEBUG_SPLINE:Boolean;
      
      public static var DISABLE_INVOKE_TOOLTIP:Boolean = false;
      
      public static var mcClazzMapCamp:Class;
      
      public static var mcClazzMapInfo:Class;
      
      private static const MARKER_WIDTH:Number = 76;
       
      
      private var gui:IGuiMapCamp;
      
      private var cmd_town_escape:Cmd;
      
      private var cmd_map_ff:Cmd;
      
      private var cmd_map_tt:Cmd;
      
      private var guiInfo:IGuiMapInfo;
      
      private var saga:Saga;
      
      private var splineMarkerWrapper:DisplayObjectWrapper;
      
      private var _splineIcon:DisplayObjectWrapper;
      
      private var _splineIconUrl:String;
      
      private var debugSprite:Sprite;
      
      private var globals:IVariableBag;
      
      private var overrideMapPt:Point;
      
      private var exitToUrl:String;
      
      private var mapSplinePt:Point;
      
      public function MapCampPage(param1:GameConfig)
      {
         this.cmd_town_escape = new Cmd("map_exit",this.cmdExitFunc);
         this.cmd_map_ff = new Cmd("map_ff",this.cmdFfFunc);
         this.cmd_map_tt = new Cmd("map_tt",this.cmdTtFunc);
         this.mapSplinePt = new Point();
         super(param1);
         enableBanner = false;
         allowPageScaling = false;
         allowTravelPage = false;
         this.saga = param1.saga;
         if(this.saga)
         {
            this.saga.addEventListener(SagaEvent.EVENT_MAP_SPLINE,this.sagaMapSplineHandler);
            this.globals = this.saga.global;
            if(this.globals)
            {
               this.globals.addEventListener(VariableEvent.TYPE,this.variableChangedHandler);
            }
            this.saga.setVar("disableInvokeMapTooltips",DISABLE_INVOKE_TOOLTIP);
         }
         param1.pageManager.addEventListener(GamePageManagerAdapter.EVENT_POPPENING,this.poppeningHandler);
      }
      
      private function variableChangedHandler(param1:VariableEvent) : void
      {
         if(Boolean(param1.value) && param1.value.def.name == SagaVar.VAR_MAP_GUI_DISABLED)
         {
            this.checkMouseEnables();
         }
      }
      
      private function sagaMapSplineHandler(param1:Event) : void
      {
         this.updateMapSpline();
      }
      
      override public function cleanup() : void
      {
         if(scene)
         {
            scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         }
         config.pageManager.removeEventListener(GamePageManagerAdapter.EVENT_POPPENING,this.poppeningHandler);
         if(this.globals)
         {
            this.globals.addEventListener(VariableEvent.TYPE,this.variableChangedHandler);
            this.globals = null;
         }
         if(this.saga)
         {
            this.saga.performStopMapCamp();
            this.saga.removeEventListener(SagaEvent.EVENT_MAP_SPLINE,this.sagaMapSplineHandler);
         }
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
         if(this.guiInfo)
         {
            this.guiInfo.cleanup();
            this.guiInfo.removeEventListener(Event.CLOSE,this.infoCompleteHandler);
            this.guiInfo = null;
         }
         this.splineIconUrl = null;
         this.splineIcon = null;
         if(this.splineMarkerWrapper)
         {
            TweenMax.killTweensOf(this.splineMarkerWrapper);
            this.splineMarkerWrapper.release();
            this.splineMarkerWrapper = null;
         }
         GpDevBinder.instance.unbind(this.cmdExitFunc);
         config.keybinder.unbind(this.cmd_town_escape);
         config.keybinder.unbind(this.cmd_map_ff);
         config.keybinder.unbind(this.cmd_map_tt);
         GpBinder.gpbinder.unbind(this.cmd_map_tt);
         this.cmd_town_escape.cleanup();
         this.cmd_town_escape = null;
         this.cmd_map_ff.cleanup();
         this.cmd_map_ff = null;
         this.cmd_map_tt.cleanup();
         this.cmd_map_tt = null;
         super.cleanup();
      }
      
      private function factoryIcon(param1:BitmapResource) : DisplayObjectWrapper
      {
         if(PlatformStarling.instance)
         {
            return new DisplayObjectWrapperStarling(new GuiIconStarling(true,param1,GuiIconLayoutType.ACTUAL));
         }
         return new DisplayObjectWrapperFlash(new GuiIcon(param1,config.gameGuiContext,GuiIconLayoutType.ACTUAL));
      }
      
      override protected function handleStart() : void
      {
         var _loc2_:CaravanDef = null;
         var _loc3_:IEntityDef = null;
         var _loc4_:String = null;
         var _loc5_:LandscapeSplineDef = null;
         super.handleStart();
         scene.addEventListener(SceneEvent.READY,this.sceneReadyHandler);
         sceneState.bannerButtonEnabled = false;
         sceneState.helpEnabled = false;
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_town_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.SPACE,this.cmd_town_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(true,false,true,Keyboard.RIGHTBRACKET,this.cmd_map_ff,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.TAB,this.cmd_map_tt,KeyBindGroup.TOWN);
         GpDevBinder.instance.bind(null,GpControlButton.A,1,this.cmdExitFunc,[null]);
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_map_tt);
         var _loc1_:BitmapResource = getPageResource("common/character/order_frame_bg_blue.png",BitmapResource) as BitmapResource;
         _loc1_.addReference();
         this.splineMarkerWrapper = this.factoryIcon(_loc1_);
         this.splineMarkerWrapper.name = "splineMarker";
         scene.landscape.enableHover = true;
         scene._camera.drift.pauseBreaksAnchor = true;
         scene._camera.drift.anchorSpeed = 2000;
         if(this.saga)
         {
            for each(_loc2_ in this.saga.def.caravans)
            {
               _loc3_ = this.saga.def.cast.getEntityDefById(_loc2_.leader);
               if(_loc3_)
               {
                  _loc4_ = _loc3_.appearance.getIconUrl(EntityIconType.INIT_ORDER);
                  getPageResource(_loc4_,BitmapResource);
               }
            }
            if(this.saga.mapCampCinema)
            {
            }
            if(this.saga.mapCampSpline)
            {
               _loc5_ = scene.landscape.def.getSplineDef(this.saga.mapCampSpline);
               if(_loc5_)
               {
                  this.overrideMapPt = new Point();
                  _loc5_.spline.sample(this.saga.mapCampSplineT,this.overrideMapPt);
               }
            }
         }
         this.updateMapSpline();
         this.updateMapCamera();
         this.checkMouseEnables();
      }
      
      private function get ready() : Boolean
      {
         if(scene && scene.ready && !wiping && !scene.paused)
         {
            if(!config.pageManager.poppening && !config.pageManager.war)
            {
               return true;
            }
         }
         return false;
      }
      
      override public function set wiping(param1:Boolean) : void
      {
         super.wiping = param1;
         this.checkMouseEnables();
      }
      
      private function checkMouseEnables() : void
      {
         var _loc1_:Boolean = this.ready;
         this.checkLandscapeHover(_loc1_);
         if(this.gui)
         {
            this.gui.guiMapCampEnabled = _loc1_ && !this.saga.mapCampCinema && !this.saga.getVarBool(SagaVar.VAR_MAP_GUI_DISABLED);
         }
      }
      
      private function checkLandscapeHover(param1:Boolean) : void
      {
         if(Boolean(scene) && Boolean(scene.landscape))
         {
            param1 = param1 && (!this.gui || !this.gui.guiMapCampHoverExit);
            scene.landscape.enableHover = param1;
         }
      }
      
      private function updateMapCamera() : void
      {
         if(this.overrideMapPt)
         {
            scene._camera.setPosition(this.overrideMapPt.x,this.overrideMapPt.y);
         }
         else
         {
            scene._camera.setPosition(this.mapSplinePt.x,this.mapSplinePt.y);
         }
      }
      
      override protected function handleLoaded() : void
      {
         super.handleLoaded();
         if(Boolean(this.saga) && this.saga.mapCampCinema)
         {
            controller.enabled = false;
         }
         if(mcClazzMapCamp)
         {
            if(!this.gui)
            {
               this.gui = new mcClazzMapCamp() as IGuiMapCamp;
               this.gui.init(config.gameGuiContext,this);
               addChild(this.gui as MovieClip);
            }
         }
         if(!this.saga || !this.saga.mapCampCinema)
         {
            if(mcClazzMapInfo)
            {
               if(!this.guiInfo)
               {
                  this.guiInfo = new mcClazzMapInfo() as IGuiMapInfo;
                  this.guiInfo.init(config.gameGuiContext);
                  this.guiInfo.addEventListener(Event.CLOSE,this.infoCompleteHandler);
               }
            }
         }
         if(DEBUG_SPLINE)
         {
            this.debugSprite = new Sprite();
         }
         this.updateMapSpline();
         this.updateMapSplineMarker();
         this.updateMapCamera();
         if(this._splineIcon)
         {
            this.splineMarkerWrapper.removeChild(this._splineIcon);
            this.splineMarkerWrapper.addChild(this._splineIcon);
         }
         this.resizeHandler();
         this.checkMouseEnables();
      }
      
      private function poppeningHandler(param1:Event) : void
      {
         this.checkMouseEnables();
      }
      
      private function sceneReadyHandler(param1:SceneEvent) : void
      {
         if(this.ready)
         {
            scene.removeEventListener(SceneEvent.READY,this.sceneReadyHandler);
         }
         this.checkMouseEnables();
      }
      
      private function infoCompleteHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = this.guiInfo as MovieClip;
         if(_loc2_.parent)
         {
            removeChild(_loc2_);
         }
         if(this.gui)
         {
            (this.gui as MovieClip).visible = true;
         }
         if(!PlatformInput.lastInputGp)
         {
            view.landscapeView.pressedClickable = null;
            view.landscapeView.displayHover(null);
         }
         controller.enabled = true;
         view.mouseEnabled = true;
         if(this.saga)
         {
            this.saga.triggerMapInfo(null);
         }
      }
      
      override protected function handleDelayStart() : void
      {
         super.handleDelayStart();
         bringContainerToFront();
      }
      
      override protected function handleLandscapeClick(param1:String) : Boolean
      {
         var _loc5_:MovieClip = null;
         var _loc6_:LandscapeSpriteDef = null;
         var _loc2_:String = StringUtil.stripPrefix(param1,"click_");
         var _loc3_:String = config.context.locale.translate(LocaleCategory.LORE,_loc2_ + "_name");
         var _loc4_:String = config.context.locale.translate(LocaleCategory.LORE,_loc2_ + "_desc");
         if(this.guiInfo)
         {
            _loc5_ = this.guiInfo as MovieClip;
            if(!_loc4_)
            {
               _loc4_ = "Description coming soon...";
            }
            this.guiInfo.showMapInfo(_loc3_,_loc4_);
            if(!_loc5_.parent)
            {
               addChild(_loc5_);
               if(this.gui)
               {
                  (this.gui as MovieClip).visible = false;
               }
               controller.enabled = false;
               view.mouseEnabled = false;
               _loc6_ = scene._def.landscape.findClickable(param1) as LandscapeSpriteDef;
               view.landscapeView.pressedClickable = _loc6_;
            }
            if(this.saga)
            {
               this.saga.triggerMapInfo(_loc2_);
            }
            return true;
         }
         return sceneState.handleLandscapeClick(param1);
      }
      
      public function cmdExitFunc(param1:CmdExec) : void
      {
         if(this.ready)
         {
            if(Boolean(this.guiInfo) && this.guiInfo.movieClip.visible)
            {
               this.guiInfo.closeMapInfo();
               return;
            }
            if(this.gui.guiMapCampEnabled)
            {
               this.guiMapCampExit();
            }
         }
      }
      
      public function cmdFfFunc(param1:CmdExec) : void
      {
         if(this.ready)
         {
            if(!this.saga || !this.saga.mapCampCinema)
            {
               this.guiMapCampExit();
               return;
            }
         }
         if(controller)
         {
            controller.doFf();
         }
      }
      
      public function cmdTtFunc(param1:CmdExec) : void
      {
         if(!PlatformInput.isGp)
         {
            view.landscapeView.showTooltips = !view.landscapeView.showTooltips;
         }
      }
      
      public function guiMapCampHoverExit() : void
      {
         this.checkLandscapeHover(this.ready);
      }
      
      public function guiMapCampExit() : void
      {
         if(!this.saga || !this.saga.mapCampCinema)
         {
            config.saga.performStopMapCamp();
         }
      }
      
      override protected function resizeHandler() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         super.resizeHandler();
         var _loc1_:Number = Math.min(1.5,BoundedCamera.dpiFingerScale * Platform.textScale);
         if(this.gui)
         {
            _loc2_ = this.gui as MovieClip;
            _loc2_.x = width / 2;
            _loc2_.y = height;
            _loc2_.scaleX = _loc2_.scaleY = _loc1_;
         }
         if(this.guiInfo)
         {
            _loc2_ = this.guiInfo as MovieClip;
            _loc2_.x = width / 2;
            _loc2_.y = height / 2;
            _loc2_.scaleX = _loc2_.scaleY = 1;
            _loc3_ = Math.min(width / _loc2_.width,height / _loc2_.height) * 0.9;
            _loc4_ = Math.min(_loc1_,_loc3_);
            _loc2_.scaleX = _loc2_.scaleY = _loc4_;
         }
      }
      
      private function updateMapSpline() : void
      {
         if(!this.saga || !this.saga.caravan)
         {
            return;
         }
         var _loc1_:String = this.saga.caravan.map_spline_id;
         var _loc2_:Landscape = !!scene ? scene.landscape : null;
         var _loc3_:LandscapeSplineDef = Boolean(_loc2_) && Boolean(_loc2_.def) ? _loc2_.def.getSplineDef(_loc1_) : null;
         if(!_loc3_)
         {
            if(Boolean(_loc1_) && Boolean(_loc2_))
            {
               logger.error("MapCampPage.updateMapSpline invalid spline id [" + _loc1_ + "]");
            }
            this.splineMarkerWrapper.visible = false;
            if(this.debugSprite)
            {
               if(this.debugSprite.parent)
               {
                  this.debugSprite.parent.removeChild(this.debugSprite);
               }
            }
            return;
         }
         this.splineMarkerWrapper.visible = true;
         view.landscapeView.addExtraToLayer(_loc3_.layer.nameId,this.splineMarkerWrapper);
         if(this.debugSprite)
         {
            addChild(this.debugSprite);
         }
         Saga.getMapSplinePoint(this.saga,this.mapSplinePt,scene._def);
         this.updateMapSplineMarkerIcon();
         this.updateMapSplineMarker();
         this.debugDraw(_loc3_);
      }
      
      private function debugDraw(param1:LandscapeSplineDef) : void
      {
         var _loc5_:LandscapeSplinePoint = null;
         var _loc6_:Number = NaN;
         if(!this.debugSprite)
         {
            return;
         }
         var _loc2_:Graphics = this.debugSprite.graphics;
         _loc2_.clear();
         _loc2_.lineStyle(3,16711935,1);
         var _loc3_:Point = new Point();
         var _loc4_:int = 0;
         while(_loc4_ <= 100)
         {
            _loc6_ = _loc4_ / 100;
            param1.spline.sample(_loc6_,_loc3_);
            if(_loc4_ == 0)
            {
               _loc2_.moveTo(_loc3_.x,_loc3_.y);
            }
            else
            {
               _loc2_.lineTo(_loc3_.x,_loc3_.y);
            }
            _loc4_++;
         }
         _loc2_.beginFill(14518527,1);
         for each(_loc5_ in param1.keyPoints)
         {
            if(_loc5_.id)
            {
               _loc2_.drawCircle(_loc5_.pos.x,_loc5_.pos.y,9);
            }
         }
         _loc2_.endFill();
      }
      
      private function updateMapSplineMarkerIcon() : void
      {
         var _loc1_:IEntityListDef = null;
         var _loc2_:IEntityDef = null;
         var _loc3_:IEntityDef = null;
         if(this.saga && this.saga.caravan && Boolean(this.saga.caravan.leader))
         {
            _loc1_ = this.saga.caravan.legend.roster;
            _loc2_ = _loc1_.getEntityDefById(this.saga.caravan.leader);
            if(_loc2_)
            {
               this.splineIconUrl = _loc2_.appearance.getIconUrl(EntityIconType.INIT_ORDER);
            }
            else if(_loc1_.numEntityDefs)
            {
               _loc3_ = _loc1_.getEntityDef(0);
               this.splineIconUrl = _loc3_.appearance.getIconUrl(EntityIconType.INIT_ORDER);
            }
         }
      }
      
      private function updateMapSplineMarker() : void
      {
         this.setVisibleMarkerPosition();
      }
      
      public function get splineIcon() : DisplayObjectWrapper
      {
         return this._splineIcon;
      }
      
      public function set splineIcon(param1:DisplayObjectWrapper) : void
      {
         if(this._splineIcon == param1)
         {
            return;
         }
         if(this._splineIcon)
         {
            this.splineMarkerWrapper.removeChild(this._splineIcon);
            this._splineIcon.release();
         }
         this._splineIcon = param1;
         if(this._splineIcon)
         {
            this._splineIcon.name = "splineIcon";
            this.splineMarkerWrapper.addChild(this._splineIcon);
            this.splineMarkerWrapper.visible = true;
            this.splineMarkerWrapper.scale = 1;
            this.splineMarkerWrapper.scale = 0;
            this.setVisibleMarkerPosition();
         }
         else
         {
            this.splineMarkerWrapper.visible = false;
            TweenMax.to(this.splineMarkerWrapper,0.2,{
               "scaleX":0,
               "scaleY":0
            });
         }
      }
      
      private function setVisibleMarkerPosition() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = this.mapSplinePt.x - MARKER_WIDTH / 2;
         var _loc2_:Number = this.mapSplinePt.y - MARKER_WIDTH / 2;
         TweenMax.killTweensOf(this.splineMarkerWrapper);
         if(this.splineMarkerWrapper.scaleX != 1)
         {
            this.splineMarkerWrapper.x = MathUtil.lerp(this.mapSplinePt.x,_loc1_,this.splineMarkerWrapper.scaleX);
            this.splineMarkerWrapper.y = MathUtil.lerp(this.mapSplinePt.y,_loc2_,this.splineMarkerWrapper.scaleY);
            _loc3_ = Math.abs(0.2 * (1 - this.splineMarkerWrapper.scaleX));
            TweenMax.to(this.splineMarkerWrapper,_loc3_,{
               "scaleX":1,
               "scaleY":1,
               "x":_loc1_,
               "y":_loc2_
            });
         }
         else
         {
            this.splineMarkerWrapper.x = _loc1_;
            this.splineMarkerWrapper.y = _loc2_;
         }
      }
      
      public function get splineIconUrl() : String
      {
         return this._splineIconUrl;
      }
      
      public function set splineIconUrl(param1:String) : void
      {
         var _loc2_:BitmapResource = null;
         if(this._splineIconUrl == param1)
         {
            return;
         }
         this._splineIconUrl = param1;
         if(this._splineIconUrl)
         {
            _loc2_ = config.resman.getResource(this._splineIconUrl,BitmapResource) as BitmapResource;
            this.splineIcon = this.factoryIcon(_loc2_);
         }
         else
         {
            this.splineIcon = null;
         }
      }
   }
}
