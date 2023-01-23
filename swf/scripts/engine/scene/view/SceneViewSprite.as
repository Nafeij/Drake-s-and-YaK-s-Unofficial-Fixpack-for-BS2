package engine.scene.view
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.convo.view.ConvoView;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.core.render.CameraDrifter;
   import engine.core.render.MatteHelper;
   import engine.gui.core.GuiSprite;
   import engine.landscape.def.LandscapeSplineDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.landscape.view.ILandscapeView;
   import engine.landscape.view.LandscapeViewConfig;
   import engine.landscape.view.LandscapeView_Flash;
   import engine.landscape.view.LandscapeView_Starling;
   import engine.math.Rng;
   import engine.math.RngSampler_SeedArray;
   import engine.saga.EnableSceneElementEvent;
   import engine.saga.EnableSceneWeatherEvent;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SceneAnimPlayEvent;
   import engine.saga.SceneCameraPanEvent;
   import engine.saga.SceneCameraSplineEvent;
   import engine.saga.SceneCameraSplinePauseEvent;
   import engine.saga.SpeakEvent;
   import engine.scene.model.Scene;
   import engine.sound.ISoundDriver;
   import flash.display.Shape;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class SceneViewSprite extends GuiSprite
   {
      
      private static var last_id:int = 0;
      
      public static const EVENT_SHOW_HELP:String = "SceneView.EVENT_SHOW_HELP";
      
      public static const EVENT_INPUT_DISABLE:String = "SceneView.EVENT_INPUT_DISABLE";
      
      public static const EVENT_INPUT_ENABLE:String = "SceneView.EVENT_INPUT_ENABLE";
      
      public static const EVENT_ZOOM_RESET:String = "SceneView.EVENT_ZOOM_RESET";
       
      
      public var scene:Scene;
      
      public var _landscapeView:ILandscapeView = null;
      
      public var matteHelper:MatteHelper;
      
      private var _showHelp:Boolean;
      
      public var shell:ShellCmdManager;
      
      public var id:int;
      
      public var boards:SceneViewBoardHelper;
      
      public var _landscapeViews:Vector.<ILandscapeView>;
      
      private var _landscapeIndex:int = -1;
      
      public var convoView:ConvoView;
      
      protected var overrideLandscapeView:ILandscapeView;
      
      private var saga:Saga;
      
      private var spliner:SceneViewCameraSpliner;
      
      private var debugShape:Shape;
      
      private var fittingCamera:Boolean;
      
      private var cleanedup:Boolean;
      
      public function SceneViewSprite(param1:Scene, param2:ISoundDriver)
      {
         var _loc4_:Rng = null;
         var _loc5_:int = 0;
         var _loc6_:ILandscapeView = null;
         this._landscapeViews = new Vector.<ILandscapeView>();
         this.debugShape = LandscapeViewConfig.DEBUG_RENDER_FRAME ? new Shape() : null;
         super();
         this.id = ++last_id;
         this.name = "scene_view";
         this.scene = param1;
         this.shell = new ShellCmdManager(param1._context.logger);
         this.spliner = new SceneViewCameraSpliner(this);
         var _loc3_:int = 1;
         if(param1.convo)
         {
            _loc3_ = 2;
         }
         this.saga = param1._context.saga as Saga;
         param1._camera.addEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
         if(param1.landscape)
         {
            if(this.overrideLandscapeView)
            {
               this._landscapeViews.push(this.overrideLandscapeView);
               addChild((this.overrideLandscapeView as LandscapeView_Flash).renderable);
            }
            else
            {
               if(Boolean(this.saga) && this.saga.camped)
               {
                  _loc4_ = RngSampler_SeedArray.ctor(this.saga.campSeed,this.saga.logger);
               }
               _loc5_ = 0;
               while(_loc5_ < _loc3_)
               {
                  if(PlatformStarling.instance)
                  {
                     _loc6_ = new LandscapeView_Starling(this,param1.landscape,-Number.MAX_VALUE,Number.MAX_VALUE,_loc4_,false,_loc5_);
                  }
                  else
                  {
                     _loc6_ = new LandscapeView_Flash(this,param1.landscape,-Number.MAX_VALUE,Number.MAX_VALUE,_loc4_,false,_loc5_);
                     addChild((_loc6_ as LandscapeView_Flash).renderable);
                  }
                  if(_loc5_ == 1)
                  {
                     _loc6_.weather.windMod = -1;
                  }
                  this._landscapeViews.push(_loc6_);
                  _loc5_++;
               }
            }
            this.landscapeIndex = 0;
         }
         this.boards = new SceneViewBoardHelper(this);
         this.matteHelper = new MatteHelper(this,param1._camera);
         this.matteHelper.visible = !PlatformStarling.instance;
         param2.reverbAmbientPreset(param1._def.reverb);
         if(param1.convo)
         {
            this.convoView = new ConvoView(param1.convo,this);
         }
         if(this.debugShape)
         {
            addChild(this.debugShape);
         }
         this.resizeHandler();
         if(this.saga)
         {
            this.saga.addEventListener(SpeakEvent.TYPE,this.speakHandler);
            this.saga.addEventListener(SagaEvent.EVENT_PAUSE,this.pauseHandler);
            this.saga.addEventListener(EnableSceneElementEvent.TYPE,this.enableSceneElementHandler);
            this.saga.addEventListener(EnableSceneWeatherEvent.TYPE,this.enableSceneWeatherHandler);
            this.saga.addEventListener(SceneAnimPlayEvent.TYPE,this.sceneAnimPlayHandler);
            this.saga.addEventListener(SceneCameraPanEvent.TYPE,this.sceneCameraPanHandler);
            this.saga.addEventListener(SceneCameraSplineEvent.TYPE,this.sceneCameraSplineHandler);
            this.saga.addEventListener(SceneCameraSplinePauseEvent.TYPE,this.sceneCameraSplinePauseHandler);
         }
         this.pauseHandler(null);
      }
      
      private function pauseHandler(param1:Event) : void
      {
         var _loc2_:* = true;
         if(this.saga)
         {
            _loc2_ = !this.saga.paused;
         }
         this.mouseChildren = this.mouseEnabled = _loc2_;
      }
      
      public function set landscapeIndex(param1:int) : void
      {
         var _loc2_:ILandscapeView = null;
         if(this.cleanedup)
         {
            return;
         }
         this._landscapeIndex = param1;
         if(param1 >= 0 && param1 < this._landscapeViews.length)
         {
            _loc2_ = this._landscapeViews[param1];
         }
         this.setLandscapeView(_loc2_);
      }
      
      public function get landscapeIndex() : int
      {
         return this._landscapeIndex;
      }
      
      private function setLandscapeView(param1:ILandscapeView) : void
      {
         var _loc2_:ILandscapeView = null;
         if(this._landscapeView == param1)
         {
            return;
         }
         if(this._landscapeView)
         {
            this.shell.removeShell("landscape");
         }
         this._landscapeView = param1;
         if(this._landscapeView)
         {
            this.shell.addShell("landscape",this._landscapeView.shell);
         }
         for each(_loc2_ in this._landscapeViews)
         {
            _loc2_.visible = param1 == _loc2_;
         }
         this.scene.landscape.layerVis = param1;
         this.resizeHandler();
      }
      
      public function get landscapeView() : ILandscapeView
      {
         return this._landscapeView;
      }
      
      private function speakHandler(param1:SpeakEvent) : void
      {
         if(this._landscapeView)
         {
            if(this._landscapeView.handleSpeak(param1,param1.anchor))
            {
               return;
            }
         }
         if(this.boards.speakHandler(param1))
         {
            return;
         }
         this.scene._context.logger.info("No speak handler found for " + param1);
      }
      
      private function sceneAnimPlayHandler(param1:SceneAnimPlayEvent) : void
      {
         if(this._landscapeView)
         {
            if(this._landscapeView.sceneAnimPlay(param1.id,param1.frame,param1.loops))
            {
               return;
            }
         }
      }
      
      private function sceneCameraPanHandler(param1:SceneCameraPanEvent) : void
      {
         var _loc2_:LandscapeSpriteDef = null;
         var _loc3_:Point = null;
         if(this.scene)
         {
            this.scene.disableStartPan();
         }
         if(this._landscapeView)
         {
            _loc2_ = this._landscapeView.getSpriteDefFromPath(param1.anchor,true);
            if(!_loc2_)
            {
               this.scene._context.logger.error("No such anchor [" + param1.anchor + "]");
            }
            else
            {
               _loc3_ = _loc2_.offsetClone.add(_loc2_.layer.offset);
               if(param1.speed > 0)
               {
                  this.scene._camera.drift.anchorSpeed = param1.speed;
               }
               this.scene._camera.drift.anchor = _loc3_;
               this.scene._camera.drift.pause = false;
            }
            this.cameraAnchorReachedHandler(null);
         }
      }
      
      private function sceneCameraSplineHandler(param1:SceneCameraSplineEvent) : void
      {
         var _loc2_:LandscapeSplineDef = null;
         if(this.scene)
         {
            this.scene.disableStartPan();
         }
         if(this._landscapeView)
         {
            _loc2_ = this._landscapeView.landscape.def.getSplineDef(param1.spline);
            if(!_loc2_)
            {
               this.scene._context.logger.error("No such spline [" + param1.spline + "]");
            }
            else
            {
               this.scene._camera.drift.anchor = null;
               this.scene._camera.drift.pause = true;
               this.spliner.addEventListener(Event.COMPLETE,this.splineCompleteHandler);
               this.spliner.setSpline(_loc2_,param1.speed,param1.time);
            }
         }
      }
      
      private function sceneCameraSplinePauseHandler(param1:SceneCameraSplinePauseEvent) : void
      {
         if(this.spliner)
         {
            this.spliner.paused = param1.paused;
         }
      }
      
      private function splineCompleteHandler(param1:Event) : void
      {
         this.spliner.removeEventListener(Event.COMPLETE,this.splineCompleteHandler);
         if(this.scene._context.saga)
         {
            (this.scene._context.saga as Saga).triggerCameraSplineComplete(this.spliner.splineId);
         }
      }
      
      private function cameraAnchorReachedHandler(param1:Event) : void
      {
         var _loc2_:CameraDrifter = this.scene._camera.drift;
         if(!_loc2_ || !_loc2_.isAnchorAnimating)
         {
            this.scene._camera.removeEventListener(Camera.EVENT_ANCHOR_REACHED,this.cameraAnchorReachedHandler);
            if(this.scene._context.saga)
            {
               (this.scene._context.saga as Saga).triggerCameraAnchorReached();
            }
         }
         else
         {
            this.scene._camera.addEventListener(Camera.EVENT_ANCHOR_REACHED,this.cameraAnchorReachedHandler);
         }
      }
      
      private function enableSceneWeatherHandler(param1:EnableSceneWeatherEvent) : void
      {
         if(Boolean(this.landscapeView) && Boolean(this.landscapeView))
         {
            this.landscapeView.weatherEnabled = param1.enabled;
         }
      }
      
      private function enableSceneElementHandler(param1:EnableSceneElementEvent) : void
      {
         if(param1.clickable)
         {
            return;
         }
         if(this._landscapeView)
         {
            if(this._landscapeView.enableSceneElement(param1.enabled,param1.id,param1.layer,param1.time))
            {
               return;
            }
         }
      }
      
      public function start() : void
      {
         if(this.convoView)
         {
            this.convoView.start();
         }
      }
      
      override public function toString() : String
      {
         return "SceneView[" + this.id + "]";
      }
      
      private function cameraViewChangedHandler(param1:Event) : void
      {
      }
      
      private function fitCamera() : void
      {
         if(this.fittingCamera)
         {
            return;
         }
         var _loc1_:BoundedCamera = !!this.scene ? this.scene._camera : null;
         if(!_loc1_)
         {
            return;
         }
         this.fittingCamera = true;
         var _loc2_:Number = width;
         var _loc3_:Number = height;
         _loc1_.fitCamera(_loc2_,_loc3_);
         this.fittingCamera = false;
      }
      
      public function update(param1:int) : void
      {
         if(!this._landscapeView || this.cleanedup)
         {
            return;
         }
         this._landscapeView.update(param1);
         this.boards.update(param1);
         if(this.convoView)
         {
            this.convoView.update(param1);
         }
      }
      
      override public function cleanup() : void
      {
         var _loc1_:ILandscapeView = null;
         if(this.cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         this.cleanedup = true;
         this.spliner.removeEventListener(Event.COMPLETE,this.splineCompleteHandler);
         this.spliner.cleanup();
         this.spliner = null;
         removeAllChildren();
         anchor = null;
         if(this.saga)
         {
            this.saga.removeEventListener(SpeakEvent.TYPE,this.speakHandler);
            this.saga.removeEventListener(SagaEvent.EVENT_PAUSE,this.pauseHandler);
            this.saga.removeEventListener(EnableSceneElementEvent.TYPE,this.enableSceneElementHandler);
            this.saga.removeEventListener(EnableSceneWeatherEvent.TYPE,this.enableSceneWeatherHandler);
            this.saga.removeEventListener(SceneAnimPlayEvent.TYPE,this.sceneAnimPlayHandler);
            this.saga.removeEventListener(SceneCameraPanEvent.TYPE,this.sceneCameraPanHandler);
            this.saga.removeEventListener(SceneCameraSplineEvent.TYPE,this.sceneCameraSplineHandler);
            this.saga.removeEventListener(SceneCameraSplinePauseEvent.TYPE,this.sceneCameraSplinePauseHandler);
         }
         if(this.convoView)
         {
            this.convoView.cleanup();
            this.convoView = null;
         }
         this.matteHelper.cleanup();
         this.matteHelper = null;
         this.boards.cleanup();
         this.boards = null;
         this.landscapeIndex = -1;
         for each(_loc1_ in this._landscapeViews)
         {
            _loc1_.cleanup();
         }
         this._landscapeViews = null;
         this._landscapeView = null;
         this.overrideLandscapeView = null;
         this.scene._camera.removeEventListener(Camera.EVENT_ANCHOR_REACHED,this.cameraAnchorReachedHandler);
         this.scene._camera.removeEventListener(Camera.EVENT_CAMERA_VIEW_CHANGED,this.cameraViewChangedHandler);
         this.shell.cleanup();
         this.shell = null;
         this.scene = null;
         removeAllChildren();
         super.cleanup();
      }
      
      override protected function resizeHandler() : void
      {
         if(this.cleanedup)
         {
            return;
         }
         super.resizeHandler();
         if(width == 0 || height == 0)
         {
            return;
         }
         if(this._landscapeView)
         {
            this._landscapeView.setPosition(width / 2,height / 2);
            this._landscapeView.handleSceneViewResize();
         }
         if(this.boards)
         {
            this.boards.resizeHandler();
         }
         this.fitCamera();
         if(this.debugShape)
         {
            this.debugShape.graphics.clear();
            this.debugShape.graphics.lineStyle(2,65535,0.8);
            this.debugShape.graphics.drawRect(0,0,width,height);
            this.debugShape.graphics.drawRect(width / 8,height / 8,width * 3 / 4,height * 3 / 4);
            this.debugShape.graphics.drawRect(width / 4,height / 4,width / 2,height / 2);
            this.debugShape.graphics.drawRect(width * 3 / 8,height * 3 / 8,width / 4,height / 4);
            this.debugShape.graphics.moveTo(0,0);
            this.debugShape.graphics.lineTo(width,height);
            this.debugShape.graphics.moveTo(width,0);
            this.debugShape.graphics.lineTo(0,height);
         }
      }
      
      public function get showHelp() : Boolean
      {
         return this._showHelp;
      }
      
      public function set showHelp(param1:Boolean) : void
      {
         if(this._landscapeView)
         {
            this._landscapeView.showHelp = param1;
         }
         if(this._showHelp != param1)
         {
            this._showHelp = param1;
            this.boards.updateShowHelp();
            dispatchEvent(new Event(EVENT_SHOW_HELP));
         }
      }
      
      public function getLandscapeView(param1:int) : ILandscapeView
      {
         return this._landscapeViews[param1];
      }
      
      public function get isSplining() : Boolean
      {
         return Boolean(this.spliner) && Boolean(this.spliner.splineId);
      }
   }
}
