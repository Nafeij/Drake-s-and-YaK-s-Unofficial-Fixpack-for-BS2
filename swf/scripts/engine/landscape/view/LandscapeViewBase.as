package engine.landscape.view
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.anim.def.AnimClipDef;
   import engine.anim.view.AnimClip;
   import engine.anim.view.ColorPulsator;
   import engine.anim.view.XAnimClipSpriteBase;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.util.ArrayUtil;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Legend;
   import engine.gui.tooltip.SimpleTooltipStyle;
   import engine.gui.tooltip.SimpleTooltipStyleDef;
   import engine.heraldry.Heraldry;
   import engine.heraldry.HeraldrySystem;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.def.LandscapeLayerDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.model.Landscape;
   import engine.landscape.model.LandscapeLayer;
   import engine.landscape.travel.model.Travel;
   import engine.landscape.travel.view.TravelView;
   import engine.math.Rng;
   import engine.resource.AnimClipResource;
   import engine.resource.BitmapResource;
   import engine.resource.IResource;
   import engine.resource.Resource;
   import engine.resource.ResourceGroup;
   import engine.resource.ResourceManager;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaVar;
   import engine.saga.SceneAnimPathEvent;
   import engine.saga.SpeakEvent;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   import engine.scene.IDisplayObjectWrapperGenerator;
   import engine.scene.SceneContext;
   import engine.scene.SceneContextEvent;
   import engine.scene.def.SceneDef;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SceneViewSprite;
   import engine.scene.view.SpeechBubble;
   import engine.sound.view.ISoundController;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class LandscapeViewBase extends EventDispatcher implements ISpeechBubblePositioner, IDisplayObjectWrapperGenerator
   {
      
      public static var DEFAULT_SHOW_PATHS:Boolean = true;
      
      public static var DEFAULT_SHOW_ANIMS:Boolean = true;
       
      
      protected var layers:Vector.<LandscapeLayerDef>;
      
      protected var isFinished:Boolean;
      
      public var _landscape:Landscape;
      
      private var spriteDef2ColorPulsator:Dictionary;
      
      private var spriteDef2Sprite:Dictionary;
      
      private var spriteDef2TravelParamSprite:Dictionary;
      
      private var animPaths:Vector.<AnimPathView>;
      
      private var spriteDef2AnimPathView:Dictionary;
      
      protected var spriteDef2Resource:Dictionary;
      
      protected var spriteDef2HoverResource:Dictionary;
      
      protected var waitingResources:Dictionary;
      
      public var layerDef2LayerSprite:Dictionary;
      
      public var resourceGroup:ResourceGroup;
      
      protected var clickables:Vector.<ClickablePair>;
      
      protected var clickablesByDef:Dictionary;
      
      private var clickPulser:LandscapeView_ClickablePulser;
      
      private var helpSpritesByDef:Dictionary;
      
      private var guidepostsByDef:Dictionary;
      
      private var guidepostStates:Dictionary;
      
      private var _pressedClickable:LandscapeSpriteDef;
      
      private var _hoverClickable:LandscapeSpriteDef;
      
      private var _showHelp:Boolean;
      
      private var _showAnchors:Boolean = false;
      
      protected var _showAnims:Boolean;
      
      protected var _showPaths:Boolean;
      
      public var _shell:ShellCmdManager;
      
      public var _clickableDefs:Vector.<LandscapeSpriteDef>;
      
      public var _travelView:TravelView;
      
      private var anims:Vector.<DisplayObjectWrapper>;
      
      private var bitmaps:Vector.<DisplayObjectWrapper>;
      
      private var anim2SpriteDef:Dictionary;
      
      private var movies:Vector.<DisplayObjectWrapper>;
      
      private var movie2SpriteDef:Dictionary;
      
      private var _spriteDefWaits:Dictionary;
      
      protected var _sceneView:SceneViewSprite;
      
      public var saga:Saga;
      
      protected var _logger:ILogger;
      
      public var rng:Rng;
      
      public var layersRng:Rng;
      
      private var snow_back:WeatherLayer;
      
      private var snow_walk:WeatherLayer;
      
      private var snow_close:WeatherLayer;
      
      protected var _weather:WeatherManager;
      
      private var heraldrySystem:HeraldrySystem;
      
      private var includeLayerIds:Dictionary;
      
      public var landscapeViewWrapper:DisplayObjectWrapper;
      
      public var icon_injury:DisplayObjectWrapper;
      
      public var _hasTalkies:Boolean;
      
      private var _spriteVisiblityDict:Dictionary;
      
      private var speedLimitMin:Number;
      
      private var speedLimitMax:Number;
      
      public var tooltipStyles:Vector.<SimpleTooltipStyle>;
      
      public var tooltipStylesDict:Dictionary;
      
      public var _defaultTooltipStyleId:String;
      
      private var _speechBubblePreloads:Dictionary;
      
      private var _tmpPt:Point;
      
      private var _camViewChangeCounter:int;
      
      protected var matrix:Matrix;
      
      public var cleanedup:Boolean;
      
      private var closest:Number = 0;
      
      private var farthest:Number = 1.7976931348623157e+308;
      
      private var layerDefsById:Dictionary;
      
      private var _selectedLayerDefs:Vector.<LandscapeLayerDef>;
      
      private var _selectedClickableLayerDefs:Vector.<LandscapeLayerDef>;
      
      public var simpleTooltipsLayer:ISimpleTooltipsLayer;
      
      private var blockerInvertLayersIds:Dictionary;
      
      private var _top_walk_layer:LandscapeLayer;
      
      private var _culled_sprites:Dictionary;
      
      private var frustum_halfwidth:Number = 500;
      
      private var cull_camera_start:Point;
      
      private var cull_camera_end:Point;
      
      private var culling_loadbarrier:Boolean;
      
      private var extras_queue:Array;
      
      private var extras_added:Array;
      
      private var heraldryBmps:Vector.<DisplayObjectWrapper>;
      
      private var _heraldry:Heraldry;
      
      private var visibleAnchors:Vector.<LandscapeSpriteDef>;
      
      public var sceneSoundController:ISoundController;
      
      private var _click_rest_enabled:Boolean;
      
      public var _hasInjuries:Boolean;
      
      private var SELECT_MARGIN:int = 100;
      
      private var currentLocale:String;
      
      private var _showTooltips:Boolean = false;
      
      public function LandscapeViewBase(param1:SceneViewSprite, param2:Landscape, param3:Number, param4:Number, param5:Rng, param6:Boolean, param7:int, param8:Boolean = true)
      {
         this.layers = new Vector.<LandscapeLayerDef>();
         this.spriteDef2ColorPulsator = new Dictionary();
         this.spriteDef2Sprite = new Dictionary();
         this.spriteDef2TravelParamSprite = new Dictionary();
         this.animPaths = new Vector.<AnimPathView>();
         this.spriteDef2AnimPathView = new Dictionary();
         this.spriteDef2Resource = new Dictionary();
         this.spriteDef2HoverResource = new Dictionary();
         this.waitingResources = new Dictionary();
         this.layerDef2LayerSprite = new Dictionary();
         this.clickables = new Vector.<ClickablePair>();
         this.clickablesByDef = new Dictionary();
         this.helpSpritesByDef = new Dictionary();
         this.guidepostsByDef = new Dictionary();
         this.guidepostStates = new Dictionary();
         this._showAnims = DEFAULT_SHOW_ANIMS;
         this._showPaths = DEFAULT_SHOW_PATHS;
         this._clickableDefs = new Vector.<LandscapeSpriteDef>();
         this.anims = new Vector.<DisplayObjectWrapper>();
         this.bitmaps = new Vector.<DisplayObjectWrapper>();
         this.anim2SpriteDef = new Dictionary();
         this.movies = new Vector.<DisplayObjectWrapper>();
         this.movie2SpriteDef = new Dictionary();
         this._spriteDefWaits = new Dictionary();
         this.includeLayerIds = new Dictionary();
         this._spriteVisiblityDict = new Dictionary();
         this._speechBubblePreloads = new Dictionary();
         this._tmpPt = new Point();
         this.matrix = new Matrix();
         this.layerDefsById = new Dictionary();
         this._selectedLayerDefs = new Vector.<LandscapeLayerDef>();
         this._selectedClickableLayerDefs = new Vector.<LandscapeLayerDef>();
         this.blockerInvertLayersIds = new Dictionary();
         this._culled_sprites = new Dictionary();
         this.cull_camera_start = new Point();
         this.cull_camera_end = new Point();
         this.extras_queue = [];
         this.extras_added = [];
         this.heraldryBmps = new Vector.<DisplayObjectWrapper>();
         this.visibleAnchors = new Vector.<LandscapeSpriteDef>();
         super();
         LandscapeViewConfig.showClickablesDispatcher.addEventListener(Event.CHANGE,this.showClickablesHandler,false,0,true);
         this.speedLimitMin = param3;
         this.speedLimitMax = param4;
         this._sceneView = param1;
         this._logger = param2.context.logger;
         this.resourceGroup = new ResourceGroup(this,this._logger);
         this.heraldrySystem = param2.scene._context.heraldrySystem;
         if(this.heraldrySystem)
         {
            this.heraldrySystem.addEventListener(HeraldrySystem.EVENT_SELECTED_HERALDRY,this.heraldrySystemHandler);
         }
         this.rng = param1.scene._context.rng;
         if(param5)
         {
            this.rng = param5;
         }
         var _loc9_:SceneContext = param1.scene._context;
         this.saga = _loc9_.saga as Saga;
         if(this.saga)
         {
            this.saga.addEventListener(SceneAnimPathEvent.START,this.sceneAnimPathStartHandler);
            this.saga.addEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
         }
         _loc9_.addEventListener(SceneContextEvent.LOCALE,this.sceneContextLocaleHandler);
         this.sceneContextLocaleHandler(null);
         if(!this.layersRng)
         {
            this.layersRng = this.rng;
         }
         this._landscape = param2;
         this._landscape.travelChangedViewCallback = this.travelChangedViewHandler;
         this._shell = new ShellCmdManager(param2.context.logger);
         this._weather = this.handleCreateWeatherManager();
         this.clickPulser = new LandscapeView_ClickablePulser(this);
         this.cacheLoadBarrierCulls();
         this.landscapeViewWrapper = this.createLandscapeViewWrapper();
         this.selectLayers(param7);
         this.stripOcclusions();
         this.addSelectedLayers();
         this.preloadSpeechBubbleIcons();
         this.preloadTooltipStyles();
         this.finishLoading();
         param2.camera.addEventListener(Camera.EVENT_CAMERA_SIZE_CHANGED,this.cameraSizeChanged);
         param2.camera.addEventListener(BoundedCamera.EVENT_MATTE_CHANGED,this.cameraMatteChanged);
         this._shell.add("layer_list",this.shellCmdFuncLayerList);
         this._shell.add("layer_hide",this.shellCmdFuncLayerHide);
         this._shell.add("layer_show",this.shellCmdFuncLayerShow);
         this._shell.add("sprite_list",this.shellCmdFuncSpriteList);
         this._shell.add("sprite_hide",this.shellCmdFuncSpriteHide);
         this._shell.add("sprite_show",this.shellCmdFuncSpriteShow);
         this._shell.add("bounds_clamp",this.shellCmdFuncBoundsClamp);
         this._shell.addShell("weather",this._weather.shell);
         this.cameraSizeChanged(null);
         this.cameraMatteChanged(null);
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get lookingForReady() : Boolean
      {
         return this._sceneView.scene.lookingForReady;
      }
      
      public function get weather() : WeatherManager
      {
         return this._weather;
      }
      
      public function get shell() : ShellCmdManager
      {
         return this._shell;
      }
      
      public function get landscape() : Landscape
      {
         return this._landscape;
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
      }
      
      public function localToGlobal(param1:Point) : Point
      {
         return null;
      }
      
      public function globalToLocal(param1:Point) : Point
      {
         return null;
      }
      
      public function get sceneView() : SceneViewSprite
      {
         return this._sceneView;
      }
      
      public function get travelView() : TravelView
      {
         return this._travelView;
      }
      
      public function get isSceneReady() : Boolean
      {
         return Boolean(this._landscape) && Boolean(this._landscape.scene) && this._landscape.scene.ready;
      }
      
      public function get clickableDefs() : Vector.<LandscapeSpriteDef>
      {
         return this._clickableDefs;
      }
      
      public function get defaultTooltipStyleId() : String
      {
         return this._defaultTooltipStyleId;
      }
      
      public function getTooltipStyle(param1:String) : SimpleTooltipStyle
      {
         param1 = !!param1 ? param1 : this._defaultTooltipStyleId;
         return !!this.tooltipStylesDict ? this.tooltipStylesDict[param1] : null;
      }
      
      public function preloadTooltipStyles() : void
      {
         var _loc2_:SimpleTooltipStyleDef = null;
         var _loc3_:SimpleTooltipStyle = null;
         if(!this.landscape.def.hasTooltips)
         {
            if(!LandscapeViewConfig.EDITOR_MODE)
            {
               return;
            }
         }
         var _loc1_:Vector.<SimpleTooltipStyleDef> = this.discoverTooltipStyles();
         if(!_loc1_)
         {
            return;
         }
         this.tooltipStyles = new Vector.<SimpleTooltipStyle>();
         this.tooltipStylesDict = new Dictionary();
         for each(_loc2_ in _loc1_)
         {
            if(!this.tooltipStyles.length)
            {
               this._defaultTooltipStyleId = _loc2_.id;
            }
            _loc3_ = new SimpleTooltipStyle(_loc2_);
            this.tooltipStyles.push(_loc3_);
            _loc3_.loadTooltip(this.resman,null);
            this.tooltipStylesDict[_loc3_.def.id] = _loc3_;
         }
      }
      
      private function discoverTooltipStyles() : Vector.<SimpleTooltipStyleDef>
      {
         var _loc1_:Vector.<SimpleTooltipStyleDef> = null;
         _loc1_ = new Vector.<SimpleTooltipStyleDef>();
         _loc1_.push(SimpleTooltipStyleDef.genericSmall_norm);
         _loc1_.push(SimpleTooltipStyleDef.genericLarge_norm);
         _loc1_.push(SimpleTooltipStyleDef.genericSmall_dark);
         _loc1_.push(SimpleTooltipStyleDef.genericLarge_dark);
         return _loc1_;
      }
      
      private function preloadSpeechBubbleIcons() : void
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:String = null;
         var _loc5_:Legend = null;
         var _loc6_:int = 0;
         var _loc7_:IBattleEntity = null;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         if(!this.saga)
         {
            return;
         }
         var _loc1_:SceneDef = this._sceneView.scene._def;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:BattleBoard = this._sceneView.scene.focusedBoard;
         _loc1_.getSpeechBubbleEntities(this._speechBubblePreloads);
         for(_loc4_ in this._speechBubblePreloads)
         {
            if(_loc4_ == "*player")
            {
               if(_loc2_)
               {
                  _loc5_ = Boolean(this.saga) && Boolean(this.saga.caravan) ? this.saga.caravan._legend : null;
                  if(_loc5_)
                  {
                     _loc6_ = 0;
                     while(_loc6_ < _loc5_.party.numMembers)
                     {
                        _loc3_ = _loc5_.party.getMember(_loc6_);
                        this._preloadSpeechBubbleIcon(_loc3_);
                        _loc6_++;
                     }
                  }
               }
            }
            else
            {
               if(_loc2_)
               {
                  _loc7_ = _loc2_.getEntityByIdOrByDefId(_loc4_,null,false);
                  if(_loc7_)
                  {
                     _loc3_ = _loc7_.def;
                     if(_loc3_)
                     {
                        this._preloadSpeechBubbleIcon(_loc3_);
                        continue;
                     }
                  }
               }
               if(_loc4_.charAt(0) == "$")
               {
                  _loc9_ = _loc4_.indexOf(SagaVar.VAR_BATTLE_TRIGGERING_UNIT);
                  if(_loc9_ == 1 || _loc9_ == 2 && _loc4_.charAt(1) == "{")
                  {
                     _loc8_ = true;
                  }
                  else if(_loc4_.indexOf(SagaVar.VAR_BATTLE_UNIT_ID) >= 0)
                  {
                     _loc8_ = true;
                  }
                  else if(_loc4_.indexOf(SagaVar.VAR_BATTLE_UNIT_NEXT_ID) >= 0)
                  {
                     _loc8_ = true;
                  }
                  else if(_loc4_.indexOf("$scene.") >= 0)
                  {
                     _loc8_ = true;
                  }
                  if(_loc8_)
                  {
                     this.logger.info("Preload speech bubbles contains [" + _loc4_ + "] but not preloading...");
                     continue;
                  }
               }
               _loc3_ = this.saga.getCastMember(_loc4_);
               if(!_loc3_)
               {
                  this.logger.error("Invalid cast member [" + _loc4_ + "] for preload speech bubbles in " + _loc1_.url);
               }
               else
               {
                  this._preloadSpeechBubbleIcon(_loc3_);
               }
            }
         }
      }
      
      private function _preloadSpeechBubbleIcon(param1:IEntityDef) : void
      {
         var _loc3_:String = null;
         if(!param1)
         {
            return;
         }
         var _loc2_:IEntityAppearanceDef = param1.appearance;
         if(_loc2_)
         {
            _loc3_ = _loc2_.getIconUrl(EntityIconType.ROSTER);
            if(_loc3_)
            {
               this.resman.getResource(_loc3_,BitmapResource,this.resourceGroup) as BitmapResource;
            }
         }
      }
      
      public function stopRendering() : void
      {
      }
      
      private function travelChangedViewHandler(param1:Landscape) : void
      {
         if(param1 != this._landscape)
         {
            throw new IllegalOperationError("landscape travel callback fail");
         }
         this.updateTravelView();
      }
      
      final public function updateTravelView() : void
      {
         if(Boolean(this._travelView) && (!this.landscape || this._travelView.travel != this.landscape.travel))
         {
            this._travelView.displayObjectWrapper.removeFromParent();
            this._travelView.cleanup();
            this._travelView = null;
         }
         if(Boolean(this.landscape) && Boolean(this.landscape.travel))
         {
            this._travelView = new TravelView(this._landscape.travel,this);
            this.landscapeViewWrapper.addChild(this._travelView.displayObjectWrapper);
         }
      }
      
      public function handleSceneViewResize() : void
      {
      }
      
      public function createLandscapeViewWrapper() : DisplayObjectWrapper
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function handleCreateWeatherManager() : WeatherManager
      {
         return null;
      }
      
      private function collectGroup(param1:Array, param2:int, param3:int) : int
      {
         var _loc4_:String = null;
         var _loc5_:LandscapeLayerDef = this._landscape.def.getLayerDef(param2) as LandscapeLayerDef;
         if(!this.checkLayer(_loc5_,param3))
         {
            return ++param2;
         }
         _loc4_ = _loc5_.randomGroup;
         param1.push(_loc5_);
         param2++;
         if(!_loc5_.randomGroup || StringUtil.isWhitespace(_loc5_.randomGroup) || !LandscapeViewConfig.allowRandomLayers)
         {
            return param2;
         }
         while(param2 < this._landscape.def.numLayerDefs)
         {
            _loc5_ = this._landscape.def.getLayerDef(param2) as LandscapeLayerDef;
            if(this.checkLayer(_loc5_,param3))
            {
               if(_loc5_.randomGroup != _loc4_ || StringUtil.isWhitespace(_loc5_.randomGroup))
               {
                  break;
               }
               param1.push(_loc5_);
            }
            param2++;
         }
         return param2;
      }
      
      private function _ensureBackground() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         var _loc2_:LandscapeSpriteDef = null;
         var _loc3_:Rectangle = null;
         if(!LandscapeViewConfig.EDITOR_MODE)
         {
            if(!LandscapeViewConfig.ENABLE_BITMAPS)
            {
               _loc1_ = new LandscapeLayerDef(this.landscape.def);
               _loc1_.nameId = "___grey_bg_layer";
               _loc2_ = new LandscapeSpriteDef(_loc1_);
               _loc2_.nameId = "___grey_bg_sprite";
               _loc2_.bmp = LandscapeViewConfig.GREY_BITMAPS_URL;
               _loc3_ = this.landscape.def.boundary;
               _loc2_.scaleX = _loc3_.width;
               _loc2_.scaleY = _loc3_.height;
               _loc2_.offsetX = _loc3_.x;
               _loc2_.offsetY = _loc3_.y;
               _loc1_.layerSprites.push(_loc2_);
               this.landscape.def.layers.insertAt(0,_loc1_);
            }
         }
      }
      
      private function selectLayers(param1:int) : void
      {
         var _loc4_:LandscapeLayerDef = null;
         var _loc2_:Array = [];
         this._ensureBackground();
         var _loc3_:int = 0;
         while(_loc3_ < this.landscape.def.numLayerDefs)
         {
            if(_loc2_.length)
            {
               _loc2_.splice(0,_loc2_.length);
            }
            _loc3_ = this.collectGroup(_loc2_,_loc3_,param1);
            if(_loc2_.length > 0)
            {
               _loc4_ = this.pickOneLayer(_loc2_);
               this.selectLayerDef(_loc4_);
            }
         }
      }
      
      private function checkLayer(param1:LandscapeLayerDef, param2:int) : Boolean
      {
         if(this.includeLayerIds[param1.nameId])
         {
            return true;
         }
         if(param1.speed <= this.speedLimitMin || param1.speed > this.speedLimitMax)
         {
            return false;
         }
         if(!LandscapeViewConfig.allowConditions)
         {
            return true;
         }
         if(param1.viewIndex >= 0)
         {
            return param2 == param1.viewIndex;
         }
         if(param1.ifCondition)
         {
            if(!this.saga.expression.evaluate(param1.ifCondition,true))
            {
               if(this._logger.isDebugEnabled)
               {
                  this._logger.debug("checkLayer SKIP-IF " + param1 + " via [" + param1.ifCondition + "]");
               }
               return false;
            }
            if(this._logger.isDebugEnabled)
            {
               this._logger.debug("checkLayer OK-IF " + param1 + " via [" + param1.ifCondition + "]");
            }
         }
         if(param1.notCondition)
         {
            if(this.saga.expression.evaluate(param1.notCondition,true))
            {
               if(this._logger.isDebugEnabled)
               {
                  this._logger.debug("checkLayer SKIP-NOT " + param1 + " via [" + param1.notCondition + "]");
               }
               return false;
            }
            if(this._logger.isDebugEnabled)
            {
               this._logger.debug("checkLayer OK-NOT " + param1 + " via [" + param1.notCondition + "]");
            }
         }
         if(param1.requireLayer)
         {
            if(!this.layerDefsById[param1.requireLayer])
            {
               return false;
            }
         }
         return true;
      }
      
      private function pickOneLayer(param1:Array) : LandscapeLayerDef
      {
         var _loc2_:LandscapeLayerDef = null;
         var _loc3_:int = 0;
         if(!param1 || param1.length == 0)
         {
            return null;
         }
         if(param1.length == 1)
         {
            return param1[0];
         }
         for each(_loc2_ in param1)
         {
            if(this.includeLayerIds[_loc2_.nameId])
            {
               return _loc2_;
            }
         }
         _loc3_ = this.layersRng.nextMax(param1.length - 1);
         return param1[_loc3_];
      }
      
      public function handleSpeak(param1:SpeakEvent, param2:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:LandscapeSpriteDef = null;
         if(!this.landscape || !this.landscape.def)
         {
            this._logger.error("Speaking into dead scene");
            return true;
         }
         var _loc3_:String = "landscape.";
         if(Boolean(param2) && param2.indexOf(_loc3_) == 0)
         {
            _loc4_ = param2.substr(_loc3_.length);
            _loc5_ = this.getSpriteDefFromPath(_loc4_,true);
            if(!_loc5_)
            {
               this._logger.error("No such anchor or sprite found: [" + param2 + "] in " + this._sceneView.scene._def.url);
            }
            else
            {
               this.sceneView.scene._context.createSpeechBubble(param1,_loc5_,this);
            }
            return true;
         }
         if(this._travelView)
         {
            if(this._travelView.handleSpeak(param1,param2))
            {
               return true;
            }
         }
         return false;
      }
      
      public function positionSpeechBubble(param1:SpeechBubble) : void
      {
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:Point = null;
         var _loc2_:BoundedCamera = this.camera;
         var _loc3_:LandscapeSpriteDef = param1.positionerInfo as LandscapeSpriteDef;
         var _loc4_:DisplayObjectWrapper = this.getDisplayForSpriteDef(_loc3_);
         var _loc5_:* = this.landscape.scene.focusedBoard != null;
         if(_loc4_)
         {
            param1.setPosition((_loc6_.x + _loc4_.x) * _loc2_.scale,(_loc6_.y + _loc4_.y) * _loc2_.scale,_loc5_);
            return;
         }
         if(_loc3_.anchor)
         {
            _loc6_ = this.getLayerSprite(null,_loc3_.layer);
            if(_loc6_)
            {
               if(_loc5_)
               {
                  this._tmpPt.setTo((_loc6_.x + _loc3_.offsetX) * _loc2_.scale,(_loc6_.y + _loc3_.offsetY) * _loc2_.scale);
                  param1.setPosition(this._tmpPt.x,this._tmpPt.y,true);
               }
               else
               {
                  this._tmpPt.setTo(_loc6_.x + _loc3_.offsetX,_loc6_.y + _loc3_.offsetY);
                  _loc7_ = this.landscapeViewWrapper.localToGlobal(this._tmpPt);
                  param1.setPosition(_loc7_.x,_loc7_.y,false);
               }
               return;
            }
         }
      }
      
      public function getSpriteDisplayFromPath(param1:String, param2:Boolean) : DisplayObjectWrapper
      {
         var _loc3_:LandscapeSpriteDef = this.getSpriteDefFromPath(param1,param2);
         if(_loc3_)
         {
            return this.getDisplayForSpriteDef(_loc3_);
         }
         return this.getExtraSpriteDisplayFromPath(param1);
      }
      
      public function getExtraSpriteDisplayFromPath(param1:String) : DisplayObjectWrapper
      {
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:DisplayObjectWrapper = null;
         if(!param1)
         {
            throw new ArgumentError("getSpriteDefFromPath invalid path");
         }
         if(!this.landscape)
         {
            return null;
         }
         var _loc2_:LandscapeLayerDef = null;
         var _loc3_:int = param1.indexOf(".");
         var _loc5_:String = param1;
         if(_loc3_ >= 0)
         {
            _loc4_ = param1.substring(0,_loc3_);
            _loc5_ = param1.substring(_loc3_ + 1);
         }
         for each(_loc6_ in this.extras_added)
         {
            _loc7_ = _loc6_.layerSprite;
            _loc8_ = _loc6_.sprite;
            if(!(!_loc7_ || !_loc8_))
            {
               if(!(Boolean(_loc4_) && _loc7_.name != _loc4_))
               {
                  if(_loc8_.name == _loc5_)
                  {
                     return _loc8_;
                  }
               }
            }
         }
         return null;
      }
      
      public function getSpriteDefFromPath(param1:String, param2:Boolean) : LandscapeSpriteDef
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:LandscapeSpriteDef = null;
         if(!param1)
         {
            throw new ArgumentError("getSpriteDefFromPath invalid path");
         }
         if(!this.landscape)
         {
            return null;
         }
         var _loc3_:LandscapeLayerDef = null;
         var _loc4_:int = param1.indexOf(".");
         if(_loc4_ >= 0)
         {
            _loc5_ = param1.substring(0,_loc4_);
            _loc6_ = param1.substring(_loc4_ + 1);
            _loc3_ = this.landscape.def.getLayer(_loc5_) as LandscapeLayerDef;
            if(_loc3_)
            {
               return _loc3_.getSprite(_loc6_);
            }
            _loc7_ = !!this.landscape.def.sceneDef ? this.landscape.def.sceneDef.url : "NONE";
            if(param2)
            {
               this._logger.error("No such layer: " + _loc5_ + " for sprite [" + param1 + "] in scene " + _loc7_);
            }
         }
         else
         {
            for each(_loc3_ in this.layers)
            {
               _loc8_ = _loc3_.getSprite(param1);
               if(_loc8_)
               {
                  return _loc8_;
               }
            }
         }
         return null;
      }
      
      public function getAnchorPoint(param1:String) : Point
      {
         var _loc7_:DisplayObjectWrapper = null;
         var _loc2_:int = param1.indexOf(".");
         if(_loc2_ < 0)
         {
            this._logger.error("no layer name in anchor path [" + param1 + "]");
            return null;
         }
         var _loc3_:String = param1.substring(0,_loc2_);
         var _loc4_:String = param1.substring(_loc2_ + 1);
         if(!this.landscape.def)
         {
            this._logger.error("WHY IS THERE NO LANDSCAPE DEF");
            return null;
         }
         var _loc5_:LandscapeLayerDef = this.landscape.def.getLayer(_loc3_) as LandscapeLayerDef;
         if(!_loc5_)
         {
            this._logger.error("no layer found for anchor path [" + param1 + "]");
            return null;
         }
         var _loc6_:Point = _loc5_.getPoint(_loc4_);
         if(_loc6_)
         {
            _loc7_ = this.layerDef2LayerSprite[_loc5_];
            if(_loc7_)
            {
               return new Point(_loc6_.x + _loc7_.x,_loc6_.y + _loc7_.y);
            }
         }
         return null;
      }
      
      final public function update(param1:int) : void
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:LandscapeView_TravelParamSprite = null;
         var _loc5_:Object = null;
         var _loc6_:AnimPathView = null;
         var _loc7_:ColorPulsator = null;
         var _loc8_:DisplayObjectWrapper = null;
         if(this.cleanedup)
         {
            return;
         }
         var _loc2_:Boolean = this.updateDelta();
         this._weather.update(param1);
         if(!this.saga || !this.saga.isOptionsShowing)
         {
            for each(_loc6_ in this.animPaths)
            {
               _loc6_.update(param1);
            }
         }
         for each(_loc3_ in this.anims)
         {
            _loc3_.update(param1);
         }
         if(this._travelView)
         {
            this._travelView.update(param1);
         }
         for each(_loc4_ in this.spriteDef2TravelParamSprite)
         {
            _loc4_.update();
         }
         for(_loc5_ in this.spriteDef2ColorPulsator)
         {
            _loc7_ = this.spriteDef2ColorPulsator[_loc5_];
            _loc8_ = this.spriteDef2Sprite[_loc5_];
            _loc7_.update(param1);
            if(_loc7_.hasColor)
            {
               _loc8_.color = _loc7_.color;
            }
            _loc8_.alpha = _loc7_.alpha;
         }
         this.handleUpdate(param1);
         this.clickPulser.update(param1);
         if(this._camViewChangeCounter != this.camera.viewChangeCounter || _loc2_)
         {
            this._camViewChangeCounter = this.camera.viewChangeCounter;
            this.updateTooltips();
         }
      }
      
      protected function handleUpdate(param1:int) : void
      {
      }
      
      protected function handleCleanup() : void
      {
      }
      
      public function cleanup() : void
      {
         var _loc2_:AnimPathView = null;
         var _loc3_:ClickablePair = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc5_:Object = null;
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:Resource = null;
         var _loc9_:DisplayObjectWrapper = null;
         var _loc10_:SimpleTooltipStyle = null;
         var _loc11_:Resource = null;
         if(this.cleanedup)
         {
            return;
         }
         var _loc1_:SceneContext = this.sceneView.scene._context;
         _loc1_.removeEventListener(SceneContextEvent.LOCALE,this.sceneContextLocaleHandler);
         this.sceneSoundController = null;
         if(this.landscapeViewWrapper)
         {
            this.landscapeViewWrapper.removeAllChildren();
            this.landscapeViewWrapper = null;
         }
         for each(_loc2_ in this.animPaths)
         {
            _loc2_.cleanup();
         }
         this.animPaths = null;
         this.spriteDef2AnimPathView = null;
         for each(_loc3_ in this.clickables)
         {
            _loc3_.cleanup();
         }
         for each(_loc4_ in this.bitmaps)
         {
            if(_loc4_)
            {
               TweenMax.killTweensOf(_loc4_);
               _loc4_.release();
            }
         }
         this.bitmaps = null;
         this.clickables = null;
         this._shell.cleanup();
         this._shell = null;
         if(this._weather)
         {
            this._weather.cleanup();
            this._weather = null;
            this.snow_back = null;
            this.snow_close = null;
            this.snow_walk = null;
         }
         if(this.simpleTooltipsLayer)
         {
            this.simpleTooltipsLayer.cleanup();
            this.simpleTooltipsLayer = null;
         }
         if(this.heraldrySystem)
         {
            this.heraldrySystem.removeEventListener(HeraldrySystem.EVENT_SELECTED_HERALDRY,this.heraldrySystemHandler);
         }
         if(this.saga)
         {
            this.saga.removeEventListener(SceneAnimPathEvent.START,this.sceneAnimPathStartHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.sagaPauseHandler);
            this.saga = null;
         }
         LandscapeViewConfig.showClickablesDispatcher.removeEventListener(Event.CHANGE,this.showClickablesHandler);
         if(this.travelView)
         {
            this._travelView.cleanup();
            this._travelView = null;
         }
         this.landscape.camera.removeEventListener(Camera.EVENT_CAMERA_SIZE_CHANGED,this.cameraSizeChanged);
         this.landscape.camera.removeEventListener(BoundedCamera.EVENT_MATTE_CHANGED,this.cameraMatteChanged);
         for each(_loc5_ in this._spriteDefWaits)
         {
            _loc11_ = _loc5_ as Resource;
            _loc11_.removeResourceListener(this.spriteDefCompleteHandler);
         }
         for each(_loc6_ in this.anims)
         {
            _loc6_.cleanup();
         }
         this.anims = null;
         this.anim2SpriteDef = null;
         for each(_loc7_ in this.movies)
         {
            _loc7_.release();
         }
         this.movies = null;
         this.movie2SpriteDef = null;
         for each(_loc8_ in this.waitingResources)
         {
            _loc8_.removeResourceListener(this.resourceCompleteHandler);
         }
         for each(_loc9_ in this.layerDef2LayerSprite)
         {
            _loc9_.removeAllChildren();
         }
         this.resourceGroup.release();
         this.resourceGroup = null;
         this.spriteDef2Resource = null;
         this.spriteDef2HoverResource = null;
         this.waitingResources = null;
         this._landscape = null;
         this.layerDef2LayerSprite = null;
         this._spriteDefWaits = null;
         for each(_loc10_ in this.tooltipStyles)
         {
            _loc10_.cleanup();
         }
         this.tooltipStyles = null;
         this.handleCleanup();
         this.cleanedup = true;
      }
      
      protected function cameraSizeChanged(param1:Event) : void
      {
      }
      
      protected function cameraMatteChanged(param1:Event) : void
      {
      }
      
      public function get selectedLayerDefs() : Vector.<LandscapeLayerDef>
      {
         return this._selectedLayerDefs;
      }
      
      public function get resman() : ResourceManager
      {
         return this._sceneView.scene._context.resman;
      }
      
      private function stripOcclusions() : void
      {
         var _loc1_:Boolean = false;
         var _loc3_:LandscapeLayerDef = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:LandscapeLayerDef = null;
         var _loc7_:int = 0;
         if(!LandscapeViewConfig.allowOcclusionLayers)
         {
            return;
         }
         var _loc2_:int = int(this._selectedLayerDefs.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._selectedLayerDefs[_loc2_];
            if(_loc3_)
            {
               if(Boolean(_loc3_.occludes) && _loc3_.occludes.length > 0)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_.occludes.length)
                  {
                     _loc5_ = String(_loc3_.occludes[_loc4_]);
                     if(_loc5_ == "*")
                     {
                        _loc7_ = _loc2_ - 1;
                        while(_loc7_ >= 0)
                        {
                           _loc6_ = this._selectedLayerDefs[_loc7_];
                           if(Boolean(_loc6_) && _loc6_.speed < _loc3_.speed)
                           {
                              _loc1_ = this.preStripOccludedLayer(_loc6_) || _loc1_;
                           }
                           _loc7_--;
                        }
                     }
                     else
                     {
                        _loc6_ = this.layerDefsById[_loc5_];
                        _loc1_ = this.preStripOccludedLayer(_loc6_) || _loc1_;
                     }
                     _loc4_++;
                  }
               }
            }
            _loc2_--;
         }
         if(_loc1_)
         {
            this.stripOccludedNulls();
         }
      }
      
      private function stripOccludedNulls() : void
      {
         var _loc1_:int = int(this._selectedLayerDefs.length - 1);
         while(_loc1_ >= 0)
         {
            if(!this._selectedLayerDefs[_loc1_])
            {
               this._selectedLayerDefs.splice(_loc1_,1);
            }
            _loc1_--;
         }
      }
      
      private function preStripOccludedLayer(param1:LandscapeLayerDef) : Boolean
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = this._selectedLayerDefs.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this._selectedLayerDefs[_loc2_] = null;
               delete this.layerDefsById[param1.nameId];
               return true;
            }
         }
         return false;
      }
      
      private function addSelectedLayers() : void
      {
         var _loc2_:LandscapeLayer = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._selectedLayerDefs.length)
         {
            this.addLayerDef(this._selectedLayerDefs[_loc1_]);
            _loc1_++;
         }
         if(Boolean(this._weather) && this._weather.enabled)
         {
            _loc2_ = this.landscape.getLayerByDef(this.layers.length > 0 ? this.layers[this.layers.length - 1] : null);
            this.snow_close = this.handleCreateSnowLayer(2,_loc2_);
         }
         this.simpleTooltipsLayer = this.handleCreateSimpleTooltipsLayer();
      }
      
      protected function handleCreateSnowLayer(param1:int, param2:LandscapeLayer) : WeatherLayer
      {
         return null;
      }
      
      protected function handleCreateSimpleTooltipsLayer() : ISimpleTooltipsLayer
      {
         return null;
      }
      
      private function selectLayerDef(param1:LandscapeLayerDef) : void
      {
         if(!param1.always && param1.numSplines == 0 && LandscapeViewConfig.OMIT_EMPTY_LAYERS)
         {
            if(!param1.layerSprites || param1.layerSprites.length == 0)
            {
               return;
            }
         }
         if(this.blockerInvertLayersIds[param1.nameId])
         {
            if(this._selectedClickableLayerDefs.length == 0)
            {
               return;
            }
         }
         this.layerDefsById[param1.nameId] = param1;
         this._selectedLayerDefs.push(param1);
         if(param1.blockInvertLayerId)
         {
            this.blockerInvertLayersIds[param1.blockInvertLayerId] = param1.nameId;
         }
         if(param1.clickBlocker)
         {
            this._selectedClickableLayerDefs.push(param1);
         }
         if(param1.includeLayer)
         {
            this.includeLayerIds[param1.includeLayer] = true;
         }
      }
      
      final private function createLayerSprite(param1:LandscapeLayerDef) : DisplayObjectWrapper
      {
         var _loc2_:DisplayObjectWrapper = this.handleCreateLayerSprite(param1);
         _loc2_.name = param1.nameId;
         this.landscapeViewWrapper.addChild(_loc2_);
         _loc2_.x = param1.offset.x;
         _loc2_.y = param1.offset.y;
         this.layerDef2LayerSprite[param1] = _loc2_;
         return _loc2_;
      }
      
      protected function handleCreateLayerSprite(param1:LandscapeLayerDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      public function addLayerDef(param1:LandscapeLayerDef) : void
      {
         var _loc2_:LandscapeLayer = null;
         var _loc4_:LandscapeSpriteDef = null;
         var _loc5_:Resource = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Resource = null;
         if(Boolean(this._weather) && this._weather.enabled)
         {
            if(this.farthest < 1)
            {
               if(param1.speed == 1 && !this.snow_back)
               {
                  _loc2_ = this.landscape.getLayerByDef(this.layers.length > 0 ? this.layers[this.layers.length - 1] : null);
                  this.snow_back = this.handleCreateSnowLayer(0,_loc2_);
               }
            }
            if(param1.speed == 1)
            {
               this._top_walk_layer = this.landscape.getLayerByDef(param1);
            }
            if(param1.speed != 1 && !this.snow_walk && Boolean(this._top_walk_layer))
            {
               this.snow_walk = this.handleCreateSnowLayer(1,this._top_walk_layer);
            }
         }
         this.closest = Math.max(this.closest,param1.speed);
         this.farthest = Math.min(this.farthest,param1.speed);
         this.layers.push(param1);
         if(param1.speed > this.camera.boundaryAdjustmentFactor)
         {
            if(!param1.disableBoundaryAdjust && param1.nameId != "layer_actors_back")
            {
               if(Boolean(param1.layerSprites) && Boolean(param1.layerSprites.length))
               {
                  this.camera.boundaryAdjustmentFactor = param1.speed;
               }
            }
         }
         var _loc3_:DisplayObjectWrapper = this.createLayerSprite(param1);
         for each(_loc4_ in param1.layerSprites)
         {
            if(!LandscapeViewConfig.spriteDefOk(this.saga,_loc4_,this._logger))
            {
               this._culled_sprites[_loc4_] = true;
            }
            else if(this.isSpriteDefCulledByClickableBlocker(_loc4_))
            {
               this._logger.info("_____ BLOCKED CLICK " + _loc4_.nameId + " " + (!!_loc4_.bmp ? _loc4_.bmp : _loc4_.anim));
               this._culled_sprites[_loc4_] = true;
            }
            else if(this.isSpriteDefCulledByLoadBarrier(_loc4_))
            {
               if(this._logger.isDebugEnabled)
               {
                  _loc6_ = !!_loc4_.localrect ? int(_loc4_.localrect.width * _loc4_.localrect.height) : 0;
                  _loc6_ *= 4;
                  _loc6_ /= 1024;
                  _loc7_ = !!_loc4_.bmp ? _loc4_.bmp : _loc4_.anim;
                  this._logger.debug("_____ CULLED SPRITE " + _loc4_.nameId + " " + _loc7_ + " kB=" + _loc6_);
               }
               this._culled_sprites[_loc4_] = true;
            }
            else if(!(_loc4_.clickable && LandscapeViewConfig.disableClickables && Boolean(_loc4_.tooltip)))
            {
               _loc5_ = this.getResourceForSpriteDef(_loc4_);
               if(_loc5_)
               {
                  if(_loc5_.ok)
                  {
                     this.processResource(_loc5_);
                  }
                  else
                  {
                     this.waitingResources[_loc5_] = _loc5_;
                     _loc5_.addEventListener(Event.COMPLETE,this.resourceCompleteHandler);
                  }
                  if(_loc4_.hover)
                  {
                     _loc8_ = this.getResourceForSpriteDefHover(_loc4_);
                     if(_loc8_.ok)
                     {
                        this.processResource(_loc8_);
                     }
                     else
                     {
                        this.waitingResources[_loc8_] = _loc8_;
                        _loc8_.addEventListener(Event.COMPLETE,this.resourceCompleteHandler);
                     }
                  }
               }
            }
         }
      }
      
      private function cacheLoadBarrierCulls() : void
      {
         if(!LandscapeViewConfig.LOAD_BARRIER_ENABLED)
         {
            return;
         }
         var _loc1_:Travel = this.landscape.travel;
         if(!_loc1_ || !_loc1_.def.loadBarrierLocations || _loc1_.def.loadBarrierLocations.length == 0)
         {
            return;
         }
         if(!_loc1_.def.spline || _loc1_.def.spline.totalLength <= 0)
         {
            return;
         }
         this.frustum_halfwidth = 10 + this.camera.width / 2;
         if(this._logger.isDebugEnabled)
         {
            this._logger.debug("LandscapeView culling_loadbarrier ON");
         }
         this.culling_loadbarrier = true;
         var _loc2_:Number = _loc1_.position;
         var _loc3_:Number = _loc1_.def.findNextLoadBarrier(_loc1_.position);
         var _loc4_:Number = _loc3_;
         var _loc5_:Number = _loc2_ / _loc1_.def.spline.totalLength;
         var _loc6_:Number = _loc4_ / _loc1_.def.spline.totalLength;
         _loc1_.def.spline.sample(_loc5_,this.cull_camera_start);
         _loc1_.def.spline.sample(_loc6_,this.cull_camera_end);
      }
      
      private function isSpriteDefCulledByClickableBlocker(param1:LandscapeSpriteDef) : Boolean
      {
         var _loc4_:LandscapeLayerDef = null;
         var _loc2_:int = int(this._selectedClickableLayerDefs.length);
         if(!param1.clickable || !_loc2_)
         {
            return false;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._selectedClickableLayerDefs[_loc3_];
            if(Boolean(_loc4_._clickBlockerBlocks) && Boolean(_loc4_._clickBlockerBlocks[param1.nameId]))
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function isSpriteDefCulledByLoadBarrier(param1:LandscapeSpriteDef) : Boolean
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(Saga.SKIP_LOCATION_TRIGGERS && !LandscapeViewConfig.LOAD_BARRIER_ENABLED)
         {
            return false;
         }
         var _loc2_:Travel = this.landscape.travel;
         if(!this.culling_loadbarrier)
         {
            return false;
         }
         if(param1.localrect.isEmpty())
         {
            return false;
         }
         if(param1.animPath)
         {
            return false;
         }
         var _loc3_:Number = param1.offsetX + param1.layer.offset.x;
         var _loc4_:Number = _loc3_ - param1.layer.speed * this.cull_camera_start.x;
         var _loc5_:Number = _loc3_ - param1.layer.speed * this.cull_camera_end.x;
         if(this.cull_camera_start.x < this.cull_camera_end.x)
         {
            _loc6_ = _loc4_ + param1.localrect.right * param1.scaleX;
            if(_loc6_ < -this.frustum_halfwidth)
            {
               return true;
            }
            _loc7_ = _loc5_ + param1.localrect.left * param1.scaleX;
            if(_loc7_ > this.frustum_halfwidth)
            {
               return true;
            }
         }
         else
         {
            _loc8_ = _loc4_ + param1.localrect.left * param1.scaleX;
            if(_loc8_ > this.frustum_halfwidth)
            {
               return true;
            }
            _loc9_ = _loc5_ + param1.localrect.right * param1.scaleX;
            if(_loc9_ < -this.frustum_halfwidth)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getResourceForSpriteDefHover(param1:LandscapeSpriteDef) : Resource
      {
         var _loc2_:Resource = this.spriteDef2HoverResource[param1];
         if(!_loc2_)
         {
            if(param1.hover)
            {
               _loc2_ = this._landscape.context.resman.getResource(param1.hover,BitmapResource,this.resourceGroup) as Resource;
            }
            this.spriteDef2HoverResource[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      private function getResourceForSpriteDef(param1:LandscapeSpriteDef) : Resource
      {
         var _loc2_:IResource = this.spriteDef2Resource[param1];
         if(!_loc2_)
         {
            if(Platform.optimizeForConsole)
            {
               if(Boolean(param1.hover) && param1.hover.indexOf("map/hover_") != -1)
               {
                  _loc2_ = this._landscape.context.resman.getResource(param1.hover,BitmapResource,this.resourceGroup);
               }
            }
            if(!_loc2_ && Boolean(param1.bmp))
            {
               _loc2_ = this._landscape.context.resman.getResource(param1.bmp,BitmapResource,this.resourceGroup);
            }
            else if(param1.anim)
            {
               _loc2_ = this._landscape.context.resman.getResource(param1.anim,AnimClipResource,this.resourceGroup);
            }
            this.spriteDef2Resource[param1] = _loc2_;
         }
         return _loc2_ as Resource;
      }
      
      public function hasLayerSprite(param1:String) : Boolean
      {
         return this.getLayerSprite(param1) != null;
      }
      
      public function getLayerSprite(param1:String = null, param2:LandscapeLayerDef = null) : DisplayObjectWrapper
      {
         var _loc4_:ILandscapeLayerDef = null;
         if(!this._landscape)
         {
            return null;
         }
         var _loc3_:DisplayObjectWrapper = null;
         if(param1 != null)
         {
            _loc4_ = this._landscape.def.getLayer(param1);
            _loc3_ = this.layerDef2LayerSprite[_loc4_];
         }
         else
         {
            _loc3_ = this.layerDef2LayerSprite[param2];
         }
         return _loc3_;
      }
      
      protected function handleCheckDisplayObjectWrapper(param1:DisplayObjectWrapper) : Boolean
      {
         return false;
      }
      
      public function addExtraToLayer(param1:String, param2:DisplayObjectWrapper) : Point
      {
         this.handleCheckDisplayObjectWrapper(param2);
         var _loc3_:ILandscapeLayerDef = this._landscape.def.getLayer(param1);
         if(!_loc3_)
         {
            this._logger.error("LandscapeView.addExtraToLayer invalid layer [" + param1 + "]" + " for scene [" + this.landscape.scene._def.url + "]");
            return null;
         }
         var _loc4_:DisplayObjectWrapper = this.getLayerSprite(param1);
         if(!_loc4_)
         {
            this._logger.error("Can\'t add to that layer: " + param1 + " for scene [" + this.landscape.scene._def.url + "]");
            return null;
         }
         if(!this.handleCheckDisplayObjectWrapper(param2))
         {
            this._logger.error("invalid sprite for layer: " + param1 + " for scene [" + this.landscape.scene._def.url + "]");
            return null;
         }
         this.extras_queue.push({
            "layerSprite":_loc4_,
            "sprite":param2
         });
         this.addExtrasToLayers();
         return _loc3_.getOffset();
      }
      
      public function addExtrasToLayers() : void
      {
         var _loc1_:Object = null;
         var _loc2_:DisplayObjectWrapper = null;
         var _loc3_:DisplayObjectWrapper = null;
         if(this.isFinished && this.extras_queue.length > 0)
         {
            for each(_loc1_ in this.extras_queue)
            {
               _loc2_ = _loc1_.layerSprite;
               _loc3_ = _loc1_.sprite;
               if(_loc2_)
               {
                  _loc2_.addChild(_loc3_);
               }
               if(_loc3_.anim)
               {
                  this.anims.push(_loc3_);
               }
               this.extras_added.push(_loc1_);
            }
            this.extras_queue = [];
         }
      }
      
      public function removeExtraFromLayer(param1:DisplayObjectWrapper) : Boolean
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.extras_added.length)
         {
            _loc3_ = this.extras_added[_loc2_];
            if(_loc3_.sprite == param1)
            {
               ArrayUtil.removeAt(this.extras_added,_loc2_);
               param1.removeFromParent();
               return true;
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.extras_queue.length)
         {
            _loc3_ = this.extras_queue[_loc2_];
            if(_loc3_.sprite == param1)
            {
               ArrayUtil.removeAt(this.extras_queue,_loc2_);
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function get camera() : BoundedCamera
      {
         return !!this._landscape ? this._landscape.camera : null;
      }
      
      protected function resourceCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         this.processResource(param1.resource);
         this.finishLoading();
      }
      
      private function processResource(param1:IResource) : void
      {
         if(param1.ok)
         {
            delete this.waitingResources[param1];
            param1.removeResourceListener(this.resourceCompleteHandler);
         }
      }
      
      public function handleSpriteDefAdded(param1:LandscapeSpriteDef, param2:DisplayObjectWrapper) : void
      {
      }
      
      protected function finishedLoading() : void
      {
      }
      
      protected function finishLoading() : void
      {
         var _loc1_:LandscapeLayerDef = null;
         var _loc2_:LandscapeSpriteDef = null;
         if(this.isWaiting)
         {
            return;
         }
         if(this.isFinished)
         {
            return;
         }
         this.isFinished = true;
         for each(_loc1_ in this.layers)
         {
            for each(_loc2_ in _loc1_.layerSprites)
            {
               this.addSpriteDef(_loc2_,false);
            }
         }
         this.clickables.reverse();
         this.addExtrasToLayers();
         this.updateDelta();
         this.updateAtmosphere();
         this.updateHeraldry();
         this.bringTooltipsToFront();
         this.simpleTooltipsLayer.sort();
      }
      
      private function heraldrySystemHandler(param1:Event) : void
      {
         this.updateHeraldry();
      }
      
      private function updateHeraldry() : void
      {
         if(!this.heraldrySystem)
         {
            return;
         }
         var _loc1_:Boolean = true;
         if(this.saga && this.saga.caravan && Boolean(this.saga.caravan.vars))
         {
            _loc1_ = this.saga.caravan.vars.getVarBool(SagaVar.VAR_HERALDRY_ENABLED);
         }
         this.heraldry = Boolean(this.heraldrySystem) && _loc1_ ? this.heraldrySystem.selectedHeraldry : null;
      }
      
      public function get heraldry() : Heraldry
      {
         return this._heraldry;
      }
      
      public function set heraldry(param1:Heraldry) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc3_:LandscapeSpriteDef = null;
         if(this._heraldry == param1)
         {
            return;
         }
         for each(_loc2_ in this.heraldryBmps)
         {
            _loc2_.removeFromParent();
            _loc2_ = null;
         }
         this.heraldryBmps.splice(0,this.heraldryBmps.length);
         this._heraldry = param1;
         if(this._heraldry)
         {
            for each(_loc3_ in this.visibleAnchors)
            {
               this.addHeraldryToAnchor(_loc3_);
            }
         }
      }
      
      private function addHeraldryToAnchor(param1:LandscapeSpriteDef) : void
      {
         if(!this._heraldry || !param1 || !param1.anchor)
         {
            return;
         }
         if(StringUtil.startsWith(param1.nameId,"anchor_heraldry_small"))
         {
            this.addHeraldryBitmapDataToAnchor(param1,this._heraldry.smallCompositeBmpd);
         }
         if(StringUtil.startsWith(param1.nameId,"anchor_heraldry_medium"))
         {
            this.addHeraldryBitmapDataToAnchor(param1,this._heraldry.mediumCompositeBmpd);
         }
         if(StringUtil.startsWith(param1.nameId,"anchor_heraldry_large"))
         {
            this.addHeraldryBitmapDataToAnchor(param1,this._heraldry.largeCompositeBmpd);
         }
      }
      
      final private function addHeraldryBitmapDataToAnchor(param1:LandscapeSpriteDef, param2:BitmapData) : void
      {
         var _loc3_:DisplayObjectWrapper = this.handeAddHeraldryBitmapDataToAnchor(param1,param2);
         if(_loc3_)
         {
            this.heraldryBmps.push(_loc3_);
         }
      }
      
      protected function handeAddHeraldryBitmapDataToAnchor(param1:LandscapeSpriteDef, param2:BitmapData) : DisplayObjectWrapper
      {
         return null;
      }
      
      private function waitForSpriteDef(param1:LandscapeSpriteDef, param2:Resource) : void
      {
         if(!this._spriteDefWaits[param2])
         {
            this._spriteDefWaits[param2] = {
               "layer":param1.layer,
               "spriteDef":param1
            };
            param2.addResourceListener(this.spriteDefCompleteHandler);
         }
      }
      
      private function spriteDefCompleteHandler(param1:ResourceLoadedEvent) : void
      {
         var _loc2_:Object = null;
         if(param1.resource)
         {
            param1.resource.removeResourceListener(this.spriteDefCompleteHandler);
            _loc2_ = this._spriteDefWaits[param1.resource];
            delete this._spriteDefWaits[param1.resource];
            if(_loc2_)
            {
               this.addSpriteDef(_loc2_.spriteDef,false);
            }
         }
      }
      
      protected function addSpriteDef(param1:LandscapeSpriteDef, param2:Boolean) : DisplayObjectWrapper
      {
         if(this._culled_sprites[param1])
         {
            return null;
         }
         var _loc3_:DisplayObjectWrapper = this.layerDef2LayerSprite[param1.layer];
         if(!_loc3_)
         {
            this._logger.error("LandscapeView.addSpriteDef no such layer: " + param1.layer);
            return null;
         }
         if(param1.clickable && LandscapeViewConfig.disableClickables)
         {
            return this.processSpriteDefDisplay(param1,_loc3_,null,null);
         }
         var _loc4_:Resource = this.spriteDef2Resource[param1];
         var _loc5_:Resource = this.spriteDef2HoverResource[param1];
         if(!_loc4_)
         {
            _loc4_ = this.getResourceForSpriteDef(param1);
         }
         if(param1.hover)
         {
            if(!_loc5_)
            {
               _loc5_ = this.getResourceForSpriteDefHover(param1);
            }
            if(!_loc5_.ok)
            {
               if(param2)
               {
                  this.waitForSpriteDef(param1,_loc5_);
               }
               else
               {
                  this._logger.error("LandscapeView.addSpriteDef Could not create " + _loc5_.url + " synchronously");
               }
               return null;
            }
         }
         if(Boolean(_loc4_) && !_loc4_.ok)
         {
            if(param2)
            {
               this.waitForSpriteDef(param1,_loc4_);
            }
            else
            {
               this._logger.error("LandscapeView.addSpriteDef Could not create " + _loc4_.url + " synchronously");
            }
            return null;
         }
         return this.processSpriteDefDisplay(param1,_loc3_,_loc4_,_loc5_);
      }
      
      private function processSpriteDefDisplay(param1:LandscapeSpriteDef, param2:DisplayObjectWrapper, param3:Resource, param4:Resource) : DisplayObjectWrapper
      {
         var _loc7_:* = false;
         var _loc8_:String = null;
         var _loc9_:ClickablePair = null;
         var _loc5_:DisplayObjectWrapper = this.generateSpriteDefDisplay(param1,param3);
         var _loc6_:DisplayObjectWrapper = null;
         if(param4)
         {
            _loc6_ = this.generateSpriteDefDisplay(param1,param4);
         }
         if(param1.nameId == "icon_injury")
         {
            this.icon_injury = _loc5_;
            this._updateIconInjury();
         }
         if(param1.clickable)
         {
            _loc8_ = this.sceneView.scene._def.url + "." + param1.layer + "." + param1.nameId;
            _loc9_ = new ClickablePair(_loc8_,this.logger,param1,param2,_loc5_,_loc6_,this.saga,this);
            this.clickables.push(_loc9_);
            this._clickableDefs.push(param1);
            this.clickablesByDef[param1] = _loc9_;
            this.clickPulser.handleClickableAdded(_loc9_);
            _loc7_ = true;
         }
         else if(param1.help)
         {
            this.helpSpritesByDef[param1] = _loc5_;
            _loc7_ = this.showHelp;
         }
         else if(param1.guidepost)
         {
            this.guidepostsByDef[param1] = _loc5_;
            if(param1.guidepost in this.guidepostStates)
            {
               _loc7_ = Boolean(this.guidepostStates[param1.guidepost]);
            }
         }
         else
         {
            _loc7_ = _loc5_ != null;
         }
         if(_loc7_)
         {
            if(param1.langs)
            {
               param1 = param1;
            }
            this.spriteDef2Sprite[param1] = _loc5_;
            if(_loc5_)
            {
               if(_loc5_.visible)
               {
                  this._checkSpriteVisibility(param1,_loc5_,this.currentLocale);
               }
               this._checkLinkedDependents(param1);
               if(param1.colorPulse)
               {
                  this.spriteDef2ColorPulsator[param1] = new ColorPulsator(param1.colorPulse);
               }
               if(param1.landscapeParams)
               {
                  if(this.landscape.travel)
                  {
                     this.spriteDef2TravelParamSprite[param1] = new LandscapeView_TravelParamSprite(this,param1,_loc5_);
                  }
               }
               param2.addChild(_loc5_);
            }
            if(param1.layer.clickBlocker)
            {
               this.addClickBlockerSprite(param1);
            }
            if(param1.debug)
            {
               _loc5_.opaqueBackground = 16711680;
            }
         }
         this.handleSpriteDefAdded(param1,_loc5_);
         this.checkSpriteAnimPath(param1);
         return _loc5_;
      }
      
      private function addClickBlockerSprite(param1:LandscapeSpriteDef) : void
      {
         if(!param1 || !param1.clickMask)
         {
            return;
         }
      }
      
      public function getAnimPathViewForSpriteDef(param1:LandscapeSpriteDef) : AnimPathView
      {
         return this.spriteDef2AnimPathView[param1];
      }
      
      public function checkSpriteAnimPath(param1:LandscapeSpriteDef) : void
      {
         var _loc5_:int = 0;
         var _loc2_:AnimPathView = this.getAnimPathViewForSpriteDef(param1);
         var _loc3_:DisplayObjectWrapper = this.getDisplayForSpriteDef(param1);
         var _loc4_:DisplayObjectWrapper = this.layerDef2LayerSprite[param1.layer];
         if(param1.animPath)
         {
            if(!_loc2_)
            {
               _loc2_ = new AnimPathView(this,param1.animPath,_loc4_,param1,_loc3_,this._logger);
               this.animPaths.push(_loc2_);
               if(_loc2_.animPathDef.autostart && this._showPaths)
               {
                  _loc2_.restart();
                  _loc2_.play();
               }
               else
               {
                  _loc2_.restart();
                  _loc2_.showing = _loc2_.animPathDef.start_visible;
               }
               this.spriteDef2AnimPathView[param1] = _loc2_;
            }
         }
         else if(_loc2_)
         {
            _loc5_ = this.animPaths.indexOf(_loc2_);
            if(_loc5_ >= 0)
            {
               this.animPaths.splice(_loc5_,1);
            }
            delete this.spriteDef2AnimPathView[param1];
            _loc2_.cleanup();
         }
      }
      
      protected function handleGenerateAnchor(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      private function generateAnchor(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         if(!this._showAnchors)
         {
            return null;
         }
         return this.handleGenerateAnchor(param1);
      }
      
      private function generateSpriteDefDisplay(param1:LandscapeSpriteDef, param2:Resource) : DisplayObjectWrapper
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc4_:AnimClip = null;
         var _loc5_:BitmapResource = null;
         var _loc6_:AnimClipResource = null;
         var _loc7_:XAnimClipSpriteBase = null;
         if(param1.anchor)
         {
            this.visibleAnchors.push(param1);
            _loc3_ = this.generateAnchor(param1);
            if(param1.nameId.indexOf("talk_") == 0)
            {
               this._hasTalkies = true;
            }
            if(!_loc3_)
            {
               return null;
            }
         }
         else if(param2)
         {
            if(param2.error)
            {
               this._logger.error("in layer " + param1.layer.nameId + " skipping error sprite nameid:[" + param1.nameId + "] url:[" + param1.bmp + "]");
               return null;
            }
            _loc5_ = param2 as BitmapResource;
            if(_loc5_)
            {
               _loc3_ = this.handleGenerateBitmap(_loc5_,param1);
               this.bitmaps.push(_loc3_);
            }
            else
            {
               _loc6_ = param2 as AnimClipResource;
               if(_loc6_)
               {
                  _loc4_ = this.generateAnimClip(_loc6_,param1);
                  if(_loc4_)
                  {
                     _loc7_ = this.handleGenerateAnimClipDisplay(_loc4_,param1.smoothing);
                     _loc3_ = _loc7_.displayObjectWrapper;
                     if(_loc3_)
                     {
                        this.anims.push(_loc3_);
                        this.anim2SpriteDef[_loc3_] = param1;
                     }
                  }
               }
            }
         }
         _loc3_ = this.createSpriteLabelDisplay(_loc3_,param1);
         if(_loc3_)
         {
            if(!param1.visible || param1.popin)
            {
               if(!LandscapeViewConfig.EDITOR_MODE)
               {
                  _loc3_.visible = false;
               }
            }
            this.updateSpriteDisplay(_loc3_,param1);
         }
         if(_loc4_)
         {
            if(LandscapeViewConfig.EDITOR_MODE || param1.autoplay && !param1.popin && param1.visible)
            {
               _loc3_.checkShowAnim(param1.loops,this._showAnims);
            }
            else
            {
               _loc4_.stop();
            }
         }
         if(_loc3_)
         {
            _loc3_.name = param1.nameId;
         }
         return _loc3_;
      }
      
      private function updateSpriteDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : void
      {
         var display:DisplayObjectWrapper = param1;
         var spriteDef:LandscapeSpriteDef = param2;
         display.name = "sprite_" + spriteDef.nameId;
         display.x = spriteDef.offsetX;
         display.y = spriteDef.offsetY;
         if(spriteDef.blendMode)
         {
            try
            {
               display.blendMode = spriteDef.blendMode;
            }
            catch(err:Error)
            {
               _logger.error("Invalid Blendmode [" + spriteDef.blendMode + "] for sprite " + spriteDef.nameId);
            }
         }
         display.scaleX = spriteDef.scaleX * spriteDef.reductionScaleX;
         display.scaleY = spriteDef.scaleY * spriteDef.reductionScaleY;
         if(spriteDef.rotation)
         {
            display.rotationDegrees = spriteDef.rotation;
         }
         if(spriteDef.label)
         {
            this.handleUpdateSpriteLabelDisplay(display,spriteDef);
         }
      }
      
      final private function createSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         if(!param2.label)
         {
            return param1;
         }
         return this.handleCreateSpriteLabelDisplay(param1,param2);
      }
      
      protected function handleCreateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      protected function handleUpdateSpriteLabelDisplay(param1:DisplayObjectWrapper, param2:LandscapeSpriteDef) : void
      {
      }
      
      private function animEventCallback(param1:AnimClip, param2:String) : void
      {
         var _loc3_:String = null;
         if(!param2)
         {
            return;
         }
         if(!this.sceneSoundController || !this.sceneSoundController.complete)
         {
            return;
         }
         if(param2.charAt(0) == "^")
         {
            _loc3_ = param2.substring(1);
            this.sceneSoundController.playSound(_loc3_,null);
         }
      }
      
      private function generateAnimClip(param1:AnimClipResource, param2:LandscapeSpriteDef) : AnimClip
      {
         var _loc6_:Saga = null;
         var _loc7_:IVariable = null;
         if(!param1)
         {
            return null;
         }
         var _loc3_:AnimClipDef = param1.clipDef;
         var _loc4_:AnimClip = new AnimClip(_loc3_,this.animEventCallback,null,this._logger);
         var _loc5_:int = param2.frame;
         if(param2.frameVar)
         {
            _loc6_ = this.sceneView.scene._context.saga as Saga;
            if(_loc6_)
            {
               _loc7_ = _loc6_.getVar(param2.frameVar,VariableType.INTEGER);
               if(_loc7_)
               {
                  _loc5_ = _loc7_.asInteger;
               }
            }
         }
         if(_loc4_.def)
         {
            _loc5_ = Math.min(_loc5_,_loc4_.def.numFrames - 1);
         }
         _loc4_.repeatLimit = param2.loops;
         _loc4_.repeatLimit = 0;
         _loc4_.start(_loc5_);
         return _loc4_;
      }
      
      protected function handleGenerateAnimClipDisplay(param1:AnimClip, param2:Boolean) : XAnimClipSpriteBase
      {
         return null;
      }
      
      public function createDisplayObjectWrapperForBitmapData(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function createDisplayObjectWrapper() : DisplayObjectWrapper
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function createBitmapDataWrapper(param1:Object, param2:BitmapData) : DisplayObjectWrapper
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function destroyBitmapDataWrapper(param1:DisplayObjectWrapper) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      protected function handleGenerateBitmap(param1:BitmapResource, param2:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         return null;
      }
      
      protected function get isWaiting() : Boolean
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:* = this.waitingResources;
         for(_loc1_ in _loc3_)
         {
            return true;
         }
         return false;
      }
      
      public function updateDeltaLayer(param1:LandscapeLayerDef) : Boolean
      {
         var _loc2_:LandscapeLayer = this._landscape.getLayerByDef(param1);
         var _loc3_:DisplayObjectWrapper = this.layerDef2LayerSprite[param1];
         if(_loc2_.offset.x != _loc3_.x || _loc2_.offset.y != _loc3_.y)
         {
            _loc3_.x = _loc2_.offset.x;
            _loc3_.y = _loc2_.offset.y;
            this.updateLayerViewVisibility(param1,_loc3_);
            return true;
         }
         return false;
      }
      
      private function updateLayerViewVisibility(param1:LandscapeLayerDef, param2:DisplayObjectWrapper) : void
      {
      }
      
      public function updateDelta() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc3_:LandscapeLayerDef = null;
         if(!this._landscape)
         {
            return false;
         }
         var _loc2_:BoundedCamera = this._landscape.camera;
         if(this.landscapeViewWrapper.scaleX != _loc2_.scale || this.landscapeViewWrapper.scaleY != _loc2_.scale)
         {
            _loc1_ = true;
            this.landscapeViewWrapper.scaleX = _loc2_.scale;
            this.landscapeViewWrapper.scaleY = _loc2_.scale;
         }
         for each(_loc3_ in this.layers)
         {
            _loc1_ = this.updateDeltaLayer(_loc3_) || _loc1_;
         }
         if(this.travelView)
         {
            if(this._travelView.displayObjectWrapper.x != -_loc2_.x || this._travelView.displayObjectWrapper.y != -_loc2_.y)
            {
               _loc1_ = true;
               this._travelView.displayObjectWrapper.x = -_loc2_.x;
               this._travelView.displayObjectWrapper.y = -_loc2_.y;
            }
         }
         return _loc1_;
      }
      
      public function getClickableUnderMouse(param1:Number, param2:Number) : LandscapeSpriteDef
      {
         var _loc3_:ClickablePair = null;
         var _loc4_:Point = null;
         var _loc5_:LandscapeLayerDef = null;
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:Point = null;
         var _loc8_:DisplayObjectWrapper = null;
         if(!this._landscape.enableHover || this.saga && this.saga.cameraPanning)
         {
            return null;
         }
         if(Boolean(this._selectedClickableLayerDefs) && Boolean(this._selectedClickableLayerDefs.length))
         {
            _loc4_ = new Point(param1,param2);
            for each(_loc5_ in this._selectedClickableLayerDefs)
            {
               _loc6_ = this.layerDef2LayerSprite[_loc5_];
               _loc7_ = _loc6_.globalToLocal(_loc4_);
               if(_loc5_.testClickBlockerMask(_loc7_.x,_loc7_.y))
               {
                  return null;
               }
            }
         }
         for each(_loc3_ in this.clickables)
         {
            _loc8_ = this.getLayerSprite(_loc3_.def.layer.nameId);
            if(!(!_loc8_ || !_loc8_.visible || !_loc8_.hasParent))
            {
               if(_loc3_.isUnderMouse(param1,param2))
               {
                  return _loc3_.def;
               }
            }
         }
         return null;
      }
      
      public function setClickableHasBeenClicked(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(_loc2_)
         {
            this.clickPulser.handleClickableClicked(_loc2_);
         }
      }
      
      public function get pressedClickable() : LandscapeSpriteDef
      {
         return this._pressedClickable;
      }
      
      public function set pressedClickable(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:ClickablePair = null;
         if(!this.landscape)
         {
            return;
         }
         if(!this._landscape.enableHover)
         {
            param1 = null;
         }
         if(this._pressedClickable)
         {
            _loc2_ = this.clickablesByDef[this._pressedClickable];
            if(_loc2_)
            {
               _loc2_.clicking = false;
            }
         }
         this._pressedClickable = param1;
         if(this._pressedClickable)
         {
            _loc2_ = this.clickablesByDef[this._pressedClickable];
            if(_loc2_)
            {
               _loc2_.clicking = true;
            }
         }
      }
      
      public function setDisplayHoverStagePosition(param1:Number, param2:Number) : void
      {
         var _loc3_:ClickablePair = this.clickablesByDef[this._hoverClickable];
         if(_loc3_)
         {
            _loc3_.setHoverStagePosition(param1,param2);
         }
      }
      
      public function setDisplayHoverStagePositionEnabled(param1:Boolean) : void
      {
         var _loc2_:ClickablePair = this.clickablesByDef[this._hoverClickable];
         if(_loc2_)
         {
            _loc2_.setHoverStagePositionEnabled(param1);
         }
      }
      
      public function displayHover(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:ClickablePair = null;
         if(!this.landscape)
         {
            return;
         }
         if(!this._landscape.enableHover)
         {
            param1 = null;
         }
         if(this._hoverClickable == param1)
         {
            return;
         }
         if(this._hoverClickable)
         {
            _loc2_ = this.clickablesByDef[this._hoverClickable];
            if(_loc2_)
            {
               _loc2_.hovering = false;
            }
         }
         this._hoverClickable = param1;
         if(this._hoverClickable)
         {
            _loc2_ = this.clickablesByDef[this._hoverClickable];
            if(_loc2_)
            {
               _loc2_.hovering = true;
            }
         }
      }
      
      public function get hoverClickable() : LandscapeSpriteDef
      {
         return this._hoverClickable;
      }
      
      public function get showHelp() : Boolean
      {
         return this._showHelp;
      }
      
      public function set showHelp(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:LandscapeSpriteDef = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc5_:DisplayObjectWrapper = null;
         if(this._showHelp != param1)
         {
            this._showHelp = param1;
            for(_loc2_ in this.helpSpritesByDef)
            {
               _loc3_ = _loc2_ as LandscapeSpriteDef;
               _loc4_ = this.helpSpritesByDef[_loc3_];
               if(param1 && !_loc4_.hasParent)
               {
                  _loc5_ = this.getLayerSprite(_loc3_.layer.nameId);
                  _loc5_.addChild(_loc4_);
               }
               else if(!param1 && _loc4_.hasParent)
               {
                  _loc4_.removeFromParent();
               }
            }
         }
      }
      
      public function sagaPauseHandler(param1:Event) : void
      {
         var _loc3_:ClickablePair = null;
         var _loc2_:Boolean = Boolean(this.saga) && this.saga.paused;
         for each(_loc3_ in this.clickables)
         {
            _loc3_.paused = _loc2_;
         }
         this.clickPulser.paused = _loc2_;
      }
      
      private function showClickablesHandler(param1:Event) : void
      {
         var _loc2_:ClickablePair = null;
         for each(_loc2_ in this.clickables)
         {
            _loc2_.updateClicking();
         }
      }
      
      public function updateAtmosphere() : void
      {
      }
      
      private function shellCmdFuncLayerList(param1:CmdExec) : void
      {
         var _loc3_:LandscapeLayerDef = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.layers)
         {
            _loc4_ = this.layerDef2LayerSprite[_loc3_];
            this._logger.info("Layer " + _loc2_ + " " + _loc3_.nameId + " visible=" + _loc4_.visible);
            _loc2_++;
         }
      }
      
      private function setLayersVisible(param1:String, param2:Boolean) : void
      {
         var _loc3_:ILandscapeLayerDef = null;
         if(param1 == "*")
         {
            for each(_loc3_ in this.layers)
            {
               this.showLayer(_loc3_,param2);
            }
            return;
         }
         var _loc4_:int = int(param1);
         _loc3_ = this._landscape.def.getLayerDef(_loc4_);
         this.showLayer(_loc3_,param2);
      }
      
      private function shellCmdFuncLayerHide(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            this.setLayersVisible(_loc2_[1],false);
         }
      }
      
      private function shellCmdFuncLayerShow(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            this.setLayersVisible(_loc2_[1],true);
         }
      }
      
      private function showLayer(param1:ILandscapeLayerDef, param2:Boolean) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:DisplayObjectWrapper = this.layerDef2LayerSprite[param1];
         if(_loc3_)
         {
            _loc3_.visible = param2;
         }
      }
      
      private function shellCmdFuncSpriteList(param1:CmdExec) : void
      {
         var _loc6_:LandscapeLayerDef = null;
         var _loc7_:LandscapeSpriteDef = null;
         var _loc8_:DisplayObjectWrapper = null;
         var _loc2_:Array = param1.param;
         var _loc3_:int = -1;
         if(_loc2_.length > 1)
         {
            _loc3_ = int(_loc2_[1]);
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this.layers.length)
         {
            if(!(_loc3_ >= 0 && _loc3_ != _loc5_))
            {
               _loc6_ = this.layers[_loc5_];
               for each(_loc7_ in _loc6_.layerSprites)
               {
                  _loc8_ = this.spriteDef2Sprite[_loc7_];
                  this._logger.info("Sprite " + _loc4_ + " " + _loc6_.nameId + "." + _loc7_.nameId + " " + (_loc8_ && _loc8_.visible));
                  _loc4_++;
               }
            }
            _loc5_++;
         }
      }
      
      private function setSpritesVisible(param1:String, param2:Boolean, param3:Number) : void
      {
         this.enableSceneElement(param2,param1,false,param3);
      }
      
      private function shellCmdFuncSpriteHide(param1:CmdExec) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            _loc3_ = 0;
            if(_loc2_.length > 2)
            {
               _loc3_ = Number(_loc2_[2]);
            }
            this.setSpritesVisible(_loc2_[1],false,_loc3_);
         }
      }
      
      private function shellCmdFuncBoundsClamp(param1:CmdExec) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            _loc3_ = BooleanVars.parse(_loc2_[1]);
            this.landscape.clampParallax = _loc3_;
         }
         this.logger.info("landscape.clampParallax=" + this.landscape.clampParallax);
      }
      
      private function shellCmdFuncSpriteShow(param1:CmdExec) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            _loc3_ = 0;
            if(_loc2_.length > 2)
            {
               _loc3_ = Number(_loc2_[2]);
            }
            this.setSpritesVisible(_loc2_[1],true,_loc3_);
         }
      }
      
      public function setGuidepostEnabled(param1:String, param2:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc4_:LandscapeSpriteDef = null;
         var _loc5_:DisplayObjectWrapper = null;
         var _loc6_:DisplayObjectWrapper = null;
         this.guidepostStates[param1] = param2;
         for(_loc3_ in this.guidepostsByDef)
         {
            _loc4_ = _loc3_ as LandscapeSpriteDef;
            if(Boolean(_loc4_) && _loc4_.guidepost == param1)
            {
               _loc5_ = this.guidepostsByDef[_loc3_];
               if(_loc5_)
               {
                  if(param2 && !_loc5_.hasParent)
                  {
                     _loc6_ = this.getLayerSprite(_loc4_.layer.nameId);
                     _loc6_.addChild(_loc5_);
                  }
                  else if(!param2 && _loc5_.hasParent)
                  {
                     _loc5_.removeFromParent();
                  }
               }
            }
         }
      }
      
      public function setClickableEnabled(param1:LandscapeSpriteDef, param2:Boolean) : Boolean
      {
         var _loc3_:* = false;
         var _loc4_:ClickablePair = this.clickablesByDef[param1];
         if(_loc4_)
         {
            _loc3_ = _loc4_.enabled != param2;
            _loc4_.enabled = param2;
            if(!param2)
            {
               if(this._hoverClickable == _loc4_.def)
               {
                  this.displayHover(null);
               }
               if(this._pressedClickable == _loc4_.def)
               {
                  this.pressedClickable = null;
               }
               _loc4_.hovering = false;
               _loc4_.clicking = false;
            }
            this.clickPulser.handleClickableEnabled(_loc4_);
         }
         if(param1.nameId.indexOf("click_rest") == 0)
         {
            this._click_rest_enabled = Boolean(_loc4_) && _loc4_.enabled;
            this._updateIconInjury();
         }
         this._checkLinkedDependents(param1);
         return _loc3_;
      }
      
      public function set hasInjuries(param1:Boolean) : void
      {
         this._hasInjuries = param1;
         this._updateIconInjury();
      }
      
      private function _updateIconInjury() : void
      {
         if(this.icon_injury)
         {
            this.icon_injury.visible = this._click_rest_enabled && this._hasInjuries || LandscapeViewConfig.EDITOR_MODE;
         }
      }
      
      public function get hasInjuries() : Boolean
      {
         return this._hasInjuries;
      }
      
      public function getClickablePair(param1:LandscapeSpriteDef) : ClickablePair
      {
         return this.clickablesByDef[param1];
      }
      
      public function getClickableDef(param1:String) : LandscapeSpriteDef
      {
         var _loc2_:ClickablePair = null;
         if(!param1)
         {
            return null;
         }
         for each(_loc2_ in this.clickables)
         {
            if(_loc2_.def.nameId == param1)
            {
               return _loc2_.def;
            }
         }
         return null;
      }
      
      public function getClickableDisplay(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         return !!_loc2_ ? _loc2_.sprite : null;
      }
      
      public function isClickableEnabled(param1:LandscapeSpriteDef) : Boolean
      {
         var _loc3_:DisplayObjectWrapper = null;
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(Boolean(_loc2_) && _loc2_.enabled)
         {
            _loc3_ = this.layerDef2LayerSprite[param1.layer];
            if(Boolean(_loc3_) && _loc3_.visible)
            {
               return true;
            }
         }
         return false;
      }
      
      public function updateSpriteDefDisplay(param1:LandscapeSpriteDef, param2:Boolean) : void
      {
         var _loc8_:ClickablePair = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:DisplayObjectWrapper = this.spriteDef2Sprite[param1];
         var _loc4_:* = param1 in this._clickableDefs;
         var _loc5_:* = param1 in this.helpSpritesByDef;
         var _loc6_:* = param1 in this.guidepostsByDef;
         var _loc7_:Boolean = param1.label != null && Boolean(param1.label);
         param2 = param2 || param1.clickable != _loc4_;
         param2 = param2 || param1.help != _loc5_;
         param2 = param2 || (!!param1.guidepost ? true : false) != _loc6_;
         param2 = param2 || (!!param1.label ? true : false) != _loc7_;
         if(param2 || !_loc3_)
         {
            _loc8_ = this.clickablesByDef[param1];
            if(_loc8_)
            {
               _loc10_ = this.clickables.indexOf(_loc8_);
               if(_loc10_ >= 0)
               {
                  this.clickables.splice(_loc10_,1);
               }
            }
            _loc9_ = this._clickableDefs.indexOf(param1);
            if(_loc9_ >= 0)
            {
               this._clickableDefs.splice(_loc9_,1);
            }
            delete this.spriteDef2Resource[param1];
            delete this.spriteDef2HoverResource[param1];
            delete this._clickableDefs[param1];
            delete this.helpSpritesByDef[param1];
            delete this.spriteDef2Sprite[param1];
            delete this.spriteDef2ColorPulsator[param1];
            delete this.spriteDef2TravelParamSprite[param1];
            if(_loc3_)
            {
               _loc3_.removeFromParent();
            }
            this.addSpriteDef(param1,true);
         }
         else
         {
            this.updateSpriteDisplay(_loc3_,param1);
         }
      }
      
      public function getDisplayForSpriteDef(param1:LandscapeSpriteDef) : DisplayObjectWrapper
      {
         var _loc2_:DisplayObjectWrapper = this.spriteDef2Sprite[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         var _loc3_:ClickablePair = this.clickablesByDef[param1];
         if(_loc3_)
         {
            return _loc3_.sprite;
         }
         return null;
      }
      
      public function forgetDisplaysForSpriteDef(param1:LandscapeSpriteDef) : void
      {
         var _loc4_:int = 0;
         var _loc2_:DisplayObjectWrapper = this.spriteDef2Sprite[param1];
         this._removeDisplay(_loc2_);
         var _loc3_:ClickablePair = this.clickablesByDef[param1];
         if(_loc3_)
         {
            this._removeDisplay(_loc3_.sprite);
            _loc4_ = this.clickables.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               ArrayUtil.removeAt(this.clickables,_loc4_);
            }
            _loc3_.cleanup();
         }
         delete this.clickablesByDef[param1];
         delete this.helpSpritesByDef[param1];
         delete this.guidepostsByDef[param1];
      }
      
      protected function handleDisplayRemoved(param1:DisplayObjectWrapper) : void
      {
      }
      
      private function _removeDisplay(param1:DisplayObjectWrapper) : void
      {
         if(param1)
         {
            param1.removeFromParent();
            this.handleDisplayRemoved(param1);
         }
      }
      
      public function get showAnchors() : Boolean
      {
         return this._showAnchors;
      }
      
      public function set showAnchors(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         var _loc3_:LandscapeSpriteDef = null;
         var _loc4_:DisplayObjectWrapper = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:LandscapeLayerDef = null;
         if(this.showAnchors == param1)
         {
            return;
         }
         this._showAnchors = param1;
         if(!this.showAnchors)
         {
            _loc5_ = [];
            for(_loc2_ in this.spriteDef2Sprite)
            {
               _loc3_ = _loc2_ as LandscapeSpriteDef;
               if(_loc3_.anchor)
               {
                  _loc4_ = this.spriteDef2Sprite[_loc2_];
                  if(_loc4_)
                  {
                     _loc4_.removeFromParent();
                  }
               }
            }
            for each(_loc3_ in _loc5_)
            {
               delete this.spriteDef2Sprite[_loc3_];
               delete this.spriteDef2TravelParamSprite[_loc3_];
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < this._landscape.def.numLayerDefs)
            {
               _loc7_ = this._landscape.def.getLayerDef(_loc6_) as LandscapeLayerDef;
               for each(_loc3_ in _loc7_.layerSprites)
               {
                  if(_loc3_.anchor)
                  {
                     _loc4_ = this.spriteDef2Sprite[_loc2_];
                     if(!_loc4_)
                     {
                        this.addSpriteDef(_loc3_,true);
                     }
                  }
               }
               _loc6_++;
            }
         }
         dispatchEvent(new LandscapeViewEvent(LandscapeViewEvent.EVENT_SHOW_ANCHORS));
      }
      
      public function enableSceneElement(param1:Boolean, param2:String, param3:Boolean, param4:Number) : void
      {
         var _loc7_:ILandscapeLayerDef = null;
         var _loc5_:DisplayObjectWrapper = null;
         if(param3)
         {
            _loc7_ = this._landscape.def.getLayer(param2);
            if(!_loc7_)
            {
               this._logger.error("enableSceneElement: " + this._landscape.scene._def.url + " LAYER [" + param2 + "] not found");
            }
            else
            {
               this.showLayer(_loc7_,param1);
            }
            return;
         }
         var _loc6_:LandscapeSpriteDef = this.getSpriteDefFromPath(param2,true);
         if(_loc6_)
         {
            if(_loc6_.clickable)
            {
               this._logger.error("Attempt to enable clickable as SPRITE: " + param2);
               return;
            }
            _loc5_ = this.spriteDef2Sprite[_loc6_];
            if(_loc5_)
            {
               this._spriteVisiblityDict[_loc6_.nameId] = param1;
               if(param4 > 0)
               {
                  if(param1)
                  {
                     this.handleTimedSpriteEnable(_loc5_,param4);
                  }
                  else
                  {
                     this.handleTimedSpriteDisable(_loc5_,param4);
                  }
                  this._checkLinkedDependents(_loc6_);
               }
               else
               {
                  this._checkSpriteVisibility(_loc6_,_loc5_,this.currentLocale);
                  if(!_loc5_.visible)
                  {
                     _loc5_.animStop();
                  }
               }
            }
         }
         else
         {
            this._logger.error("enableSceneElement: " + this._landscape.scene._def.url + " SPRITE [" + param2 + "] not found");
         }
      }
      
      private function handleTimedSpriteEnable(param1:DisplayObjectWrapper, param2:Number) : void
      {
         if(!param1.visible)
         {
            param1.alpha = 0;
            param1.visible = true;
         }
         else if(param1.alpha == 1)
         {
            return;
         }
         TweenMax.killTweensOf(param1);
         TweenMax.to(param1,param2,{"alpha":1});
      }
      
      private function handleTimedSpriteDisable(param1:DisplayObjectWrapper, param2:Number) : void
      {
         var ls:DisplayObjectWrapper = param1;
         var time:Number = param2;
         if(!ls.visible)
         {
            return;
         }
         if(ls.alpha == 0)
         {
            ls.visible = false;
            return;
         }
         TweenMax.killTweensOf(ls);
         TweenMax.to(ls,time,{
            "alpha":0,
            "onComplete":function():void
            {
               ls.visible = false;
            }
         });
      }
      
      public function sceneAnimPlay(param1:String, param2:int, param3:int) : void
      {
         var _loc5_:DisplayObjectWrapper = null;
         var _loc4_:LandscapeSpriteDef = this.getSpriteDefFromPath(param1,true);
         if(_loc4_)
         {
            _loc5_ = this.spriteDef2Sprite[_loc4_];
            if(_loc5_)
            {
               if(!_loc5_.animPlay(this.rng,param2,param3))
               {
                  this._logger.error("sceneAnimPlay: sprite is not an anim [" + param1 + "]");
               }
            }
         }
         else
         {
            this._logger.error("sceneAnimPlay: no such sprite [" + param1 + "]");
         }
      }
      
      private function sceneAnimPathStartHandler(param1:SceneAnimPathEvent) : void
      {
         var _loc2_:String = param1.id;
         var _loc3_:LandscapeSpriteDef = this.getSpriteDefFromPath(param1.id,true);
         if(!_loc3_)
         {
            this._logger.error("sceneAnimPathStartHandler: no such sprite [" + _loc2_ + "]");
            return;
         }
         var _loc4_:AnimPathView = this.spriteDef2AnimPathView[_loc3_];
         if(!_loc3_)
         {
            this._logger.error("sceneAnimPathStartHandler: sprite has no anim path [" + _loc2_ + "]");
            return;
         }
         if(_loc4_)
         {
            _loc4_.restart();
            _loc4_.play();
         }
      }
      
      public function get showAnims() : Boolean
      {
         return this._showAnims;
      }
      
      public function set showAnims(param1:Boolean) : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc3_:LandscapeSpriteDef = null;
         this._showAnims = param1;
         DEFAULT_SHOW_ANIMS = param1;
         for each(_loc2_ in this.anims)
         {
            _loc3_ = this.anim2SpriteDef[_loc2_];
            _loc2_.checkShowAnim(!!_loc3_ ? _loc3_.loops : 0,this._showAnims);
         }
         dispatchEvent(new LandscapeViewEvent(LandscapeViewEvent.EVENT_SHOW_ANIMS));
      }
      
      public function get showPaths() : Boolean
      {
         return this._showPaths;
      }
      
      public function set showPaths(param1:Boolean) : void
      {
         var _loc2_:AnimPathView = null;
         var _loc3_:Boolean = false;
         this._showPaths = param1;
         DEFAULT_SHOW_PATHS = param1;
         for each(_loc2_ in this.animPaths)
         {
            _loc3_ = this._showPaths && _loc2_.spriteDef.visible;
            _loc2_.showing = _loc3_;
            _loc2_.sprite.visible = _loc2_.showing;
         }
         dispatchEvent(new LandscapeViewEvent(LandscapeViewEvent.EVENT_SHOW_PATHS));
      }
      
      public function getLayerIfVisible(param1:String) : LandscapeLayer
      {
         var _loc2_:LandscapeLayerDef = this.layerDefsById[param1];
         var _loc3_:DisplayObjectWrapper = this.layerDef2LayerSprite[_loc2_];
         if(Boolean(_loc3_) && _loc3_.visible)
         {
            return !!this.landscape ? this.landscape.getLayerByDef(_loc2_) : null;
         }
         return null;
      }
      
      public function set weatherEnabled(param1:Boolean) : void
      {
         if(this._weather)
         {
            this._weather.enabled = param1;
         }
         if(this.snow_back)
         {
            this.snow_back.visible = param1;
         }
         if(this.snow_close)
         {
            this.snow_close.visible = param1;
         }
         if(this.snow_walk)
         {
            this.snow_walk.visible = param1;
         }
      }
      
      public function createBattleBoardView(param1:BattleBoard) : BattleBoardView
      {
         return null;
      }
      
      public function getClickableByIndex(param1:int) : LandscapeSpriteDef
      {
         var _loc2_:ClickablePair = null;
         if(param1 >= 0 && param1 < this.clickables.length)
         {
            _loc2_ = this.clickables[param1];
            return !!_loc2_ ? _loc2_.def : null;
         }
         return null;
      }
      
      public function getIndexOfClickableDef(param1:LandscapeSpriteDef) : int
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(_loc2_)
         {
            return this.clickables.indexOf(_loc2_);
         }
         return -1;
      }
      
      public function selectClickable_next(param1:LandscapeSpriteDef, param2:Point) : LandscapeSpriteDef
      {
         var _loc5_:ClickablePair = null;
         var _loc8_:ClickablePair = null;
         var _loc11_:LandscapeLayer = null;
         var _loc15_:Point = null;
         var _loc16_:ClickablePair = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         if(this.cleanedup)
         {
            return null;
         }
         var _loc3_:Number = Number.MAX_VALUE;
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc6_:Number = Number.MAX_VALUE;
         var _loc7_:Number = Number.MAX_VALUE;
         var _loc9_:Number = this.camera.width / 2;
         var _loc10_:Number = this.camera.height / 2;
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         if(param2)
         {
            _loc15_ = this.globalToLocal(param2);
            _loc12_ = _loc15_.x;
            _loc13_ = _loc15_.y;
         }
         var _loc14_:int = 0;
         while(_loc14_ < this.clickables.length)
         {
            _loc16_ = this.clickables[_loc14_];
            if(!(!_loc16_.enabled || _loc16_.def == param1 || !_loc16_.def.clickMask))
            {
               _loc11_ = this.landscape.getLayerByDef(_loc16_.def.layer);
               _loc17_ = _loc16_.def.scaleX * _loc16_.def.clickMask.width / 2;
               _loc18_ = _loc16_.def.scaleY * _loc16_.def.clickMask.height / 2;
               _loc19_ = _loc17_ / 2;
               _loc20_ = _loc18_ / 2;
               _loc21_ = _loc16_.def.offsetX + _loc11_.offset.x + _loc17_;
               _loc22_ = _loc16_.def.offsetY + _loc11_.offset.y + _loc18_;
               if(!(_loc21_ < -_loc9_ + this.SELECT_MARGIN - _loc19_ || _loc21_ > _loc9_ - this.SELECT_MARGIN + _loc19_ || _loc22_ < -_loc10_ + this.SELECT_MARGIN - _loc20_ || _loc22_ > _loc10_ - this.SELECT_MARGIN + _loc20_))
               {
                  if(_loc21_ < _loc3_ || _loc21_ == _loc3_ && (!_loc5_ || _loc22_ < _loc4_))
                  {
                     _loc4_ = _loc22_;
                     _loc3_ = _loc21_;
                     _loc5_ = _loc16_;
                  }
                  if(param2)
                  {
                     if(_loc21_ > _loc12_ || _loc21_ == _loc12_ && _loc22_ > _loc13_)
                     {
                        if(_loc21_ < _loc6_ || _loc21_ == _loc6_ && (!_loc8_ || _loc22_ < _loc7_))
                        {
                           _loc6_ = _loc21_;
                           _loc7_ = _loc22_;
                           _loc8_ = _loc16_;
                        }
                     }
                  }
               }
            }
            _loc14_++;
         }
         if(_loc8_)
         {
            return _loc8_.def;
         }
         if(_loc5_)
         {
            return _loc5_.def;
         }
         return null;
      }
      
      public function selectClickable_prev(param1:LandscapeSpriteDef, param2:Point) : LandscapeSpriteDef
      {
         var _loc5_:ClickablePair = null;
         var _loc8_:ClickablePair = null;
         var _loc11_:LandscapeLayer = null;
         var _loc15_:Point = null;
         var _loc16_:ClickablePair = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         if(this.cleanedup)
         {
            return null;
         }
         var _loc3_:Number = -Number.MAX_VALUE;
         var _loc4_:Number = -Number.MAX_VALUE;
         var _loc6_:Number = -Number.MAX_VALUE;
         var _loc7_:Number = -Number.MAX_VALUE;
         var _loc9_:Number = this.camera.width / 2;
         var _loc10_:Number = this.camera.height / 2;
         var _loc12_:Number = 0;
         var _loc13_:Number = 0;
         if(param2)
         {
            _loc15_ = this.globalToLocal(param2);
            _loc12_ = _loc15_.x;
            _loc13_ = _loc15_.y;
         }
         var _loc14_:int = 0;
         while(_loc14_ < this.clickables.length)
         {
            _loc16_ = this.clickables[_loc14_];
            if(!(!_loc16_.enabled || _loc16_.def == param1 || !_loc16_.def.clickMask))
            {
               _loc11_ = this.landscape.getLayerByDef(_loc16_.def.layer);
               _loc17_ = _loc16_.def.scaleX * _loc16_.def.clickMask.width / 2;
               _loc18_ = _loc16_.def.scaleY * _loc16_.def.clickMask.height / 2;
               _loc19_ = _loc17_ / 2;
               _loc20_ = _loc18_ / 2;
               _loc21_ = _loc16_.def.offsetX + _loc11_.offset.x + _loc17_;
               _loc22_ = _loc16_.def.offsetY + _loc11_.offset.y + _loc18_;
               if(!(_loc21_ < -_loc9_ + this.SELECT_MARGIN - _loc19_ || _loc21_ > _loc9_ - this.SELECT_MARGIN + _loc19_ || _loc22_ < -_loc10_ + this.SELECT_MARGIN - _loc20_ || _loc22_ > _loc10_ - this.SELECT_MARGIN + _loc20_))
               {
                  if(_loc21_ > _loc3_ || _loc21_ == _loc3_ && (!_loc5_ || _loc22_ > _loc4_))
                  {
                     _loc4_ = _loc22_;
                     _loc3_ = _loc21_;
                     _loc5_ = _loc16_;
                  }
                  if(param2)
                  {
                     if(_loc21_ < _loc12_ || _loc21_ == _loc12_ && _loc22_ < _loc13_)
                     {
                        if(_loc21_ > _loc6_ || _loc21_ == _loc6_ && (!_loc8_ || _loc22_ > _loc7_))
                        {
                           _loc6_ = _loc21_;
                           _loc7_ = _loc22_;
                           _loc8_ = _loc16_;
                        }
                     }
                  }
               }
            }
            _loc14_++;
         }
         if(_loc8_)
         {
            return _loc8_.def;
         }
         if(_loc5_)
         {
            return _loc5_.def;
         }
         return null;
      }
      
      public function getClickablePointGlobal(param1:LandscapeSpriteDef) : Point
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(_loc2_)
         {
            return _loc2_.getCenterPointGlobal();
         }
         return null;
      }
      
      public function getClickableRectGlobal(param1:LandscapeSpriteDef) : Rectangle
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(_loc2_)
         {
            return _loc2_.getRectGlobal();
         }
         return null;
      }
      
      public function getClickablePointLocal(param1:LandscapeSpriteDef) : Point
      {
         var _loc3_:Point = null;
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(_loc2_)
         {
            _loc3_ = _loc2_.getCenterPointLocal();
            if(_loc3_)
            {
               if(param1.layer)
               {
                  _loc3_.x += param1.layer.offset.x;
                  _loc3_.y += param1.layer.offset.y;
               }
               return _loc3_;
            }
         }
         return null;
      }
      
      public function updateClickables() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:LandscapeSpriteDef = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         for each(_loc2_ in this.clickableDefs)
         {
            _loc3_ = _loc2_.nameId;
            _loc4_ = this.sceneView.scene.isClickableEnabled(_loc3_);
            _loc1_ = this.setClickableEnabled(_loc2_,_loc4_) || _loc1_;
         }
         if(_loc1_)
         {
            this.updateTooltips();
            dispatchEvent(new LandscapeViewEvent(LandscapeViewEvent.EVENT_CLICKABLES_CHANGED));
         }
      }
      
      public function sceneContextLocaleHandler(param1:SceneContextEvent) : void
      {
         var _loc2_:String = null;
         if(Boolean(this.saga) && Boolean(this.saga.locale))
         {
            _loc2_ = this.saga.locale.id._id;
         }
         this.currentLocale = _loc2_;
         this.updateLangs(_loc2_);
      }
      
      public function updateLangs(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:LandscapeSpriteDef = null;
         var _loc4_:DisplayObjectWrapper = null;
         for(_loc2_ in this.spriteDef2Sprite)
         {
            _loc3_ = _loc2_ as LandscapeSpriteDef;
            _loc4_ = this.spriteDef2Sprite[_loc2_];
            if(Boolean(_loc3_) && Boolean(_loc4_))
            {
               this._checkSpriteVisibility(_loc3_,_loc4_,param1);
            }
         }
         this.updateTooltips();
      }
      
      private function _checkSpriteVisibility(param1:LandscapeSpriteDef, param2:DisplayObjectWrapper, param3:String) : void
      {
         if(!param2)
         {
            param2 = this.spriteDef2Sprite[param1];
            if(!param2)
            {
               return;
            }
         }
         if(param2 == this.icon_injury)
         {
            this._updateIconInjury();
            return;
         }
         var _loc4_:Boolean = this._computeSpriteVisibility(param1,param3);
         if(param2.visible != _loc4_)
         {
            param2.visible = _loc4_;
            if(_loc4_)
            {
               if(!param1.clickable)
               {
                  param2.alpha = 1;
               }
            }
            this._checkLinkedDependents(param1);
         }
      }
      
      private function _computeSpriteVisibility(param1:LandscapeSpriteDef, param2:String) : Boolean
      {
         if(this._culled_sprites[param1] != undefined)
         {
            return false;
         }
         var _loc3_:* = this._spriteVisiblityDict[param1.nameId];
         if(_loc3_ != undefined && _loc3_ == false)
         {
            return false;
         }
         var _loc4_:ClickablePair = this.clickablesByDef[param1];
         if(_loc4_)
         {
            if(!_loc4_.enabled)
            {
               return false;
            }
         }
         var _loc5_:Boolean = LandscapeViewConfig.EDITOR_MODE || !param2 || param1.checkLang(param2);
         return _loc5_ && this._checkLinkedDependency(param1);
      }
      
      public function _checkLinkedDependency(param1:LandscapeSpriteDef) : Boolean
      {
         if(!param1)
         {
            throw new ArgumentError("need a LandscapeSpriteDef");
         }
         if(!param1.linked)
         {
            return true;
         }
         return this._computeSpriteVisibility(param1.linked,this.currentLocale);
      }
      
      public function _checkLinkedDependents(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:LandscapeSpriteDef = null;
         if(!param1)
         {
            throw new ArgumentError("need a LandscapeSpriteDef");
         }
         if(!param1.linkedFrom)
         {
            return;
         }
         for each(_loc2_ in param1.linkedFrom)
         {
            this._checkSpriteVisibility(_loc2_,null,this.currentLocale);
         }
      }
      
      public function resetAnimPaths() : void
      {
         var _loc1_:AnimPathView = null;
         if(!this._showPaths)
         {
            return;
         }
         for each(_loc1_ in this.animPaths)
         {
            _loc1_.reset();
            if(_loc1_.spriteDef.visible)
            {
               _loc1_.sprite.visible = true;
            }
            else
            {
               _loc1_.sprite.visible = true;
            }
            if(_loc1_.animPathDef.autostart)
            {
               _loc1_.restart();
               _loc1_.play();
            }
         }
      }
      
      public function get hasTalkies() : Boolean
      {
         return this._hasTalkies;
      }
      
      public function get showTooltips() : Boolean
      {
         return this._showTooltips;
      }
      
      public function set showTooltips(param1:Boolean) : void
      {
         this._showTooltips = param1;
         this.updateTooltips();
      }
      
      public function bringTooltipsToFront() : void
      {
         var _loc1_:ClickablePair = null;
         for each(_loc1_ in this.clickables)
         {
            _loc1_.bringTooltipToFront();
         }
      }
      
      public function updateTooltips() : void
      {
         var _loc1_:ClickablePair = null;
         if(this._showTooltips)
         {
            for each(_loc1_ in this.clickables)
            {
               _loc1_.updateTooltip();
            }
         }
      }
      
      public function updateTooltipForClickable(param1:LandscapeSpriteDef) : void
      {
         var _loc2_:ClickablePair = this.clickablesByDef[param1];
         if(!_loc2_)
         {
            if(param1.clickable)
            {
               throw new IllegalOperationError("clickable has no pair");
            }
            return;
         }
         _loc2_.updateTooltip();
      }
   }
}
