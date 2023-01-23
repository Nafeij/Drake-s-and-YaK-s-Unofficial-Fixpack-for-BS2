package engine.convo.view
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import engine.core.logging.ILogger;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.entity.def.IEntityDef;
   import engine.gui.core.GuiSprite;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.ILandscapeView;
   import engine.saga.Saga;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoCursor;
   import engine.saga.convo.ConvoEvent;
   import engine.saga.convo.def.ConvoDef;
   import engine.scene.SceneContext;
   import engine.scene.def.SceneAudioEmitterDef;
   import engine.scene.view.SceneViewSprite;
   import engine.sound.SoundBundleWrapper;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ConvoView extends GuiSprite
   {
      
      private static var _DEBUG_MARKS:Boolean;
      
      public static const EVENT_CURSOR_SHOWN:String = "ConvoView.EVENT_CURSOR_SHOWN";
      
      public static const EVENT_CURSOR_HIDE:String = "ConvoView.EVENT_CURSOR_HIDE";
      
      public static var DISABLE_CONVO_ZOOM_FOR_CONSOLE:Boolean = false;
      
      private static var _instance:ConvoView;
      
      public static var REPORT_NARROW:Boolean;
       
      
      public var convo:Convo;
      
      public var sceneView:SceneViewSprite;
      
      public var started:Boolean;
      
      public var camera:BoundedCamera;
      
      public var layerFacingX:Number = 0;
      
      public var layerBackX:Number = 0;
      
      private var actorsBack:Vector.<Vector.<DisplayObjectWrapper>>;
      
      private var actorsFacing:Vector.<Vector.<DisplayObjectWrapper>>;
      
      private var actorsFoley:Vector.<Vector.<SceneAudioEmitterDef>>;
      
      private var logger:ILogger;
      
      private var _debugView:ConvoView_DebugView;
      
      private var panWaiting:Boolean;
      
      private var transCameraStageIndex:int = 0;
      
      private var transMarkFacing:int = 0;
      
      private var soundBundleWrapper:SoundBundleWrapper;
      
      private var flipEventId:String = "world/ui/conversations/convo_pan";
      
      private var hasVarls:Boolean;
      
      private var centerPan:Array;
      
      public var facingXs:Array;
      
      public var backXs:Array;
      
      private var facingScales:Array;
      
      private var backScales:Array;
      
      private var _attemptCamPan:Number = 0;
      
      private var panDuration:Number = 0.8;
      
      private var panDist:Number = 150;
      
      public function ConvoView(param1:Convo, param2:SceneViewSprite)
      {
         var _loc6_:DisplayObjectWrapper = null;
         this.actorsBack = new Vector.<Vector.<DisplayObjectWrapper>>();
         this.actorsFacing = new Vector.<Vector.<DisplayObjectWrapper>>();
         this.actorsFoley = new Vector.<Vector.<SceneAudioEmitterDef>>();
         this.centerPan = [-600,600,600,-600];
         this.facingXs = [-1200,1200,0,0];
         this.backXs = [1500,-1500,-2100,2100];
         this.facingScales = [1,-1,1,-1];
         this.backScales = [-1,1,-1,1];
         super();
         _instance = this;
         this.logger = param1.logger;
         var _loc3_:int = 0;
         while(_loc3_ < 4)
         {
            this.actorsBack.push(new Vector.<DisplayObjectWrapper>());
            this.actorsFacing.push(new Vector.<DisplayObjectWrapper>());
            this.actorsFoley.push(null);
            _loc3_++;
         }
         this.convo = param1;
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.sceneView = param2;
         param1.cursor.addEventListener(ConvoCursor.EVENT_JUMP,this.convoNodeHandler);
         param1.addEventListener(ConvoEvent.HIDE_ACTOR,this.convoHideActorHandler);
         param1.addEventListener(ConvoEvent.SHOW_ACTOR,this.convoShowActorHandler);
         var _loc4_:ILandscapeView = param2.getLandscapeView(0) as ILandscapeView;
         var _loc5_:ILandscapeView = param2.getLandscapeView(1) as ILandscapeView;
         _loc4_.weather.snow.densityMod = 0.8;
         _loc5_.weather.snow.densityMod = 0.8;
         _loc4_.weather.speedMod = 0.8;
         _loc5_.weather.speedMod = 0.8;
         this.checkForVarls();
         if(param1.audio)
         {
            param1.audio.generatePitches();
            if(param2.scene.audio)
            {
               param2.scene.audio.pitchSemitones = param1.audio.pitch;
            }
         }
         _loc3_ = 4;
         while(_loc3_ >= 1)
         {
            this.addActorsToLandscape(_loc3_,0);
            this.addActorsToLandscape(_loc3_,1);
            this.actorsFoley[_loc3_ - 1] = this.constructPortraitFoleys(_loc3_);
            _loc3_--;
         }
         this.renderDebugConvoView();
         this.checkActorVisibility();
         if(Boolean(this.actorsFacing[2]) && !this.actorsFacing[3])
         {
            for each(_loc6_ in this.actorsFacing[2])
            {
               _loc6_.scaleX = -1;
            }
         }
         this.handleLandscapeFlipFoley();
         this.loadCameraFlipSound();
      }
      
      public static function refreshInstanceCamera() : void
      {
         if(_instance)
         {
            _instance.refreshCamera();
         }
      }
      
      public static function get DEBUG_MARKS() : Boolean
      {
         return _DEBUG_MARKS;
      }
      
      public static function set DEBUG_MARKS(param1:Boolean) : void
      {
         if(_DEBUG_MARKS == param1)
         {
            return;
         }
         _DEBUG_MARKS = param1;
         if(_instance)
         {
            _instance.renderDebugConvoView();
         }
      }
      
      public static function isActorFacingCamera(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = ConvoDef.getCameraStageIndexForMarkDst(param1);
         return _loc3_ == param2;
      }
      
      public static function getLayerForActor(param1:Boolean) : String
      {
         if(!param1)
         {
            return "layer_actors_back";
         }
         return "layer_actors_facing";
      }
      
      private function renderDebugConvoView() : void
      {
         if(!DEBUG_MARKS)
         {
            if(this._debugView)
            {
               this._debugView.cleanup();
               this._debugView = null;
            }
         }
         else if(!this._debugView)
         {
            this._debugView = new ConvoView_DebugView(this);
            return;
         }
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "layerFacingX=" + this.layerFacingX + "\n";
         _loc1_ += "layerBackX=" + this.layerBackX + "\n";
         return _loc1_ + ("CONVO:\n" + this.convo.getDebugString());
      }
      
      private function loadCameraFlipSound() : void
      {
         var _loc1_:SceneContext = this.sceneView.scene._context;
         if(!_loc1_ || !_loc1_.soundDriver)
         {
            return;
         }
         this.soundBundleWrapper = new SoundBundleWrapper("convo_view-flip",this.flipEventId,_loc1_.soundDriver);
      }
      
      private function playCameraFlipSound() : void
      {
         if(this.soundBundleWrapper)
         {
            this.soundBundleWrapper.playSound();
         }
      }
      
      private function checkActorVisibility() : void
      {
         var _loc3_:Vector.<String> = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:DisplayObjectWrapper = null;
         var _loc7_:DisplayObjectWrapper = null;
         var _loc8_:SceneAudioEmitterDef = null;
         var _loc9_:Boolean = false;
         var _loc1_:int = this.sceneView.landscapeIndex;
         var _loc2_:int = 1;
         while(_loc2_ <= 4)
         {
            _loc3_ = this.convo.def.getUnitsFromMark(_loc2_);
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc6_ = this.actorsBack[_loc2_ - 1][_loc4_];
               _loc7_ = this.actorsFacing[_loc2_ - 1][_loc4_];
               _loc8_ = this.actorsFoley[_loc2_ - 1][_loc4_];
               _loc9_ = this.convo.isActorVisible(_loc5_);
               if(_loc8_)
               {
                  if(_loc8_.enabled != _loc9_)
                  {
                     _loc8_.enabled = _loc9_;
                     _loc8_.dirty = true;
                  }
               }
               if(_loc6_)
               {
                  _loc6_.visible = _loc9_ && !isActorFacingCamera(_loc2_,_loc1_);
               }
               if(_loc7_)
               {
                  _loc7_.visible = _loc9_ && isActorFacingCamera(_loc2_,_loc1_);
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      private function convoHideActorHandler(param1:ConvoEvent) : void
      {
      }
      
      private function convoShowActorHandler(param1:ConvoEvent) : void
      {
      }
      
      private function _isTall(param1:IEntityDef) : Boolean
      {
         return param1.entityClass.race == "varl" || param1.entityClass.race == "dredge";
      }
      
      private function checkForVarls() : void
      {
         var _loc2_:Vector.<String> = null;
         var _loc3_:String = null;
         var _loc4_:Saga = null;
         var _loc5_:IEntityDef = null;
         var _loc1_:int = 1;
         while(_loc1_ <= 4)
         {
            _loc2_ = this.convo.def.getUnitsFromMark(_loc1_);
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_)
               {
                  _loc4_ = this.sceneView.scene._context.saga as Saga;
                  _loc5_ = _loc4_.getCastMember(_loc3_);
                  if(_loc5_)
                  {
                     if(this._isTall(_loc5_))
                     {
                        this.hasVarls = true;
                        return;
                     }
                  }
               }
            }
            _loc1_++;
         }
      }
      
      private function handleLandscapeFlipFoley() : void
      {
         var _loc3_:Vector.<SceneAudioEmitterDef> = null;
         var _loc4_:int = 0;
         var _loc5_:SceneAudioEmitterDef = null;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:DisplayObjectWrapper = null;
         var _loc1_:int = this.sceneView.landscapeIndex;
         var _loc2_:int = 1;
         while(_loc2_ <= 4)
         {
            _loc3_ = this.actorsFoley[_loc2_ - 1];
            if(_loc3_)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  _loc5_ = _loc3_[_loc4_];
                  if(_loc5_)
                  {
                     _loc6_ = this.convo.def.getUnitsFromMark(_loc2_)[_loc4_];
                     if(this.convo.isActorVisible(_loc6_))
                     {
                        _loc7_ = isActorFacingCamera(_loc2_,_loc1_);
                        _loc8_ = _loc7_ ? this.actorsFacing[_loc2_ - 1][_loc4_] : this.actorsBack[_loc2_ - 1][_loc4_];
                        _loc5_.source.setTo(_loc8_.x,1162 / 2,1,1);
                        _loc5_.layer = getLayerForActor(_loc7_);
                        _loc5_.dirty = true;
                     }
                  }
                  _loc4_++;
               }
            }
            _loc2_++;
         }
      }
      
      private function addActorsToLandscape(param1:int, param2:int) : void
      {
         var _loc5_:String = null;
         var _loc3_:Vector.<String> = this.convo.def.getUnitsFromMark(param1);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            this.addActorToLandscape(param1,_loc4_,_loc5_,param2);
            _loc4_++;
         }
      }
      
      private function addActorToLandscape(param1:int, param2:int, param3:String, param4:int) : void
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         if(!param3)
         {
            return;
         }
         var _loc5_:ILandscapeView = this.sceneView.getLandscapeView(param4);
         var _loc6_:Boolean = isActorFacingCamera(param1,param4);
         var _loc7_:String = getLayerForActor(_loc6_);
         if(_loc6_)
         {
            this.actorsFacing[param1 - 1].push(null);
         }
         else
         {
            this.actorsBack[param1 - 1].push(null);
         }
         if(!_loc5_.hasLayerSprite(_loc7_))
         {
            this.logger.error("No such layer for convo actor: " + _loc7_);
            return;
         }
         var _loc8_:ILandscapeLayerDef = _loc5_.landscape.def.getLayer(_loc7_);
         var _loc9_:Saga = this.sceneView.scene._context.saga as Saga;
         var _loc10_:IEntityDef = _loc9_.getCastMember(param3);
         if(!_loc10_)
         {
            this.logger.error("Convo " + this.convo.def.url + " no such cast member [" + param3 + "] for convo mark " + param1);
            return;
         }
         var _loc11_:Number = 2;
         var _loc12_:SceneContext = this.sceneView.scene._context;
         var _loc13_:DisplayObjectWrapper = _loc12_.generateConvoPortrait(_loc10_,_loc6_,1);
         if(!_loc13_)
         {
            this.logger.error("No sprite convo actor: " + _loc10_.id + " facing=" + _loc6_);
            return;
         }
         var _loc14_:Number = 2731;
         var _loc15_:Number = 1162;
         var _loc16_:Number = _loc14_ / 2;
         _loc5_.addExtraToLayer(_loc7_,_loc13_);
         var _loc17_:Boolean = this.hasVarls && !this._isTall(_loc10_);
         _loc13_.name = param3;
         _loc13_.visible = false;
         if(_loc6_)
         {
            _loc13_.y = 1162;
            _loc18_ = Number(this.facingXs[param1 - 1]);
            _loc19_ = Number(this.facingScales[param1 - 1]);
            _loc13_.scaleX = _loc19_;
            _loc13_.x = _loc16_ + _loc18_;
            this.actorsFacing[param1 - 1][param2] = _loc13_;
         }
         else
         {
            _loc13_.y = 0;
            _loc20_ = Number(this.backXs[param1 - 1]);
            _loc21_ = Number(this.backScales[param1 - 1]);
            _loc13_.scaleX = _loc21_ * _loc11_;
            _loc13_.scaleY = _loc11_;
            _loc13_.x = _loc16_ + _loc20_;
            this.actorsBack[param1 - 1][param2] = _loc13_;
         }
         if(_loc17_)
         {
            _loc13_.y += _loc15_ / 4;
         }
      }
      
      private function constructPortraitFoleys(param1:int) : Vector.<SceneAudioEmitterDef>
      {
         var _loc4_:String = null;
         var _loc5_:SceneAudioEmitterDef = null;
         var _loc2_:Vector.<String> = this.convo.def.getUnitsFromMark(param1);
         var _loc3_:Vector.<SceneAudioEmitterDef> = new Vector.<SceneAudioEmitterDef>();
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = this.constructPortraitFoley(_loc4_,param1);
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      private function constructPortraitFoley(param1:String, param2:int) : SceneAudioEmitterDef
      {
         if(!param1)
         {
            return null;
         }
         var _loc3_:Saga = this.sceneView.scene._context.saga as Saga;
         var _loc4_:IEntityDef = _loc3_.getCastMember(param1);
         if(!_loc4_)
         {
            return null;
         }
         if(!_loc4_.appearance.portraitFoley)
         {
            return null;
         }
         var _loc5_:SceneAudioEmitterDef = new SceneAudioEmitterDef();
         _loc5_.event = _loc4_.appearance.portraitFoley;
         this.sceneView.scene.audio.addExtraEmitter(_loc5_);
         return _loc5_;
      }
      
      private function convoNodeHandler(param1:Event) : void
      {
         this.showConvoNode();
      }
      
      override public function cleanup() : void
      {
         var _loc1_:Vector.<DisplayObjectWrapper> = null;
         var _loc2_:DisplayObjectWrapper = null;
         if(_instance == this)
         {
            _instance = null;
         }
         if(this.soundBundleWrapper)
         {
            this.soundBundleWrapper.cleanup();
            this.soundBundleWrapper = null;
         }
         if(Boolean(this.convo) && Boolean(this.convo.cursor))
         {
            this.convo.cursor.removeEventListener(ConvoCursor.EVENT_JUMP,this.convoNodeHandler);
         }
         if(DISABLE_CONVO_ZOOM_FOR_CONSOLE)
         {
            Camera.ALLOW_ZOOM = true;
         }
         if(this.sceneView && this.sceneView.scene && Boolean(this.sceneView.scene._context))
         {
            for each(_loc1_ in this.actorsBack)
            {
               for each(_loc2_ in _loc1_)
               {
                  if(_loc2_)
                  {
                     _loc2_.release();
                  }
               }
            }
            for each(_loc1_ in this.actorsFacing)
            {
               for each(_loc2_ in _loc1_)
               {
                  if(_loc2_)
                  {
                     _loc2_.release();
                  }
               }
            }
         }
         this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_INPUT_ENABLE));
         TweenMax.killTweensOf(this);
         super.cleanup();
      }
      
      public function update(param1:int) : void
      {
      }
      
      public function get camPan() : Number
      {
         if(this.camera)
         {
            return this.camera.unclampedX;
         }
         return 0;
      }
      
      public function set camPan(param1:Number) : void
      {
         if(this.camera)
         {
            this.camera.unclampedX = param1;
         }
      }
      
      public function get camZoom() : Number
      {
         if(this.camera)
         {
            return this.camera.zoom;
         }
         return 0;
      }
      
      public function set camZoom(param1:Number) : void
      {
         if(this.camera)
         {
            this.camera.zoom = param1;
         }
      }
      
      public function set backOffsetX(param1:Number) : void
      {
         var _loc2_:String = null;
         if(this.camera)
         {
            _loc2_ = getLayerForActor(false);
            this.sceneView.landscapeView.landscape.modifyTransitoryLayer(_loc2_,param1,0);
         }
      }
      
      private function setupCameraTransition() : void
      {
         var _loc1_:String = this.convo.cursor.camera;
         if(_loc1_)
         {
            this.transCameraStageIndex = this.convo.cursor.cameraStageIndex;
            this.transMarkFacing = this.convo.cursor.cameraMarkFacing;
            if(this.transMarkFacing <= 0)
            {
               this.logger.error("Invalid camera mark facing " + this.transMarkFacing + " for camera " + this.convo.cursor.camera + " on " + this.convo.cursor);
            }
         }
         else if(this.convo.cursor.speakerId)
         {
            this.transMarkFacing = this.convo.def.getMarkFromUnit(this.convo.cursor.speakerId);
            this.transCameraStageIndex = ConvoDef.getCameraStageIndexForMarkDst(this.transMarkFacing);
            if(this.transMarkFacing <= 0)
            {
               this.logger.error("Invalid camera mark facing " + this.transMarkFacing + " for speaker " + this.convo.cursor.speakerId + " on " + this.convo.cursor);
            }
         }
      }
      
      public function showConvoNode() : void
      {
         dispatchEvent(new Event(EVENT_CURSOR_HIDE));
         if(this.camera)
         {
            this.camera.drift.anchor = null;
         }
         this.setupCameraTransition();
         this.checkOutStart();
         dispatchEvent(new Event(EVENT_CURSOR_SHOWN));
      }
      
      private function checkOutStart() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         this.panWaiting = false;
         if(this.sceneView.landscapeIndex != this.transCameraStageIndex)
         {
            _loc1_ = this.transCameraStageIndex == 0 ? this.panDist : -this.panDist;
            _loc2_ = this.panDuration / 2;
            _loc3_ = this.camPan - _loc1_;
            this.panWaiting = true;
            this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_INPUT_DISABLE));
            TweenMax.to(this,_loc2_,{
               "camZoom":1,
               "camPan":_loc3_,
               "ease":Quad.easeIn,
               "onComplete":this.panOutComplete
            });
         }
         if(!this.panWaiting)
         {
            this.panOutComplete();
         }
      }
      
      private function panOutComplete() : void
      {
         this.panWaiting = false;
         this.checkOutComplete();
      }
      
      private function checkOutComplete() : void
      {
         if(this.panWaiting)
         {
            return;
         }
         this.checkPanIn();
      }
      
      private function checkPanIn() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         this.panWaiting = false;
         this.checkActorVisibility();
         var _loc1_:Number = 0;
         if(this.transMarkFacing > 0)
         {
            _loc1_ = Number(this.centerPan[this.transMarkFacing - 1]);
         }
         if(this.sceneView.landscapeIndex != this.transCameraStageIndex)
         {
            this.sceneView.landscapeIndex = this.transCameraStageIndex;
            _loc2_ = this.transCameraStageIndex == 0 ? this.panDist : -this.panDist;
            this.camPan = _loc1_ + _loc2_;
            this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_INPUT_DISABLE));
            this.panWaiting = true;
            TweenMax.to(this,this.panDuration,{
               "camPan":_loc1_,
               "camZoom":1,
               "ease":Quad.easeOut,
               "onComplete":this.panInComplete
            });
            this.playCameraFlipSound();
            if(this.convo.audio)
            {
               this.convo.audio.switchPitches();
               if(this.sceneView.scene.audio)
               {
                  this.sceneView.scene.audio.pitchSemitones = this.convo.audio.pitch;
               }
            }
            this.checkActorVisibility();
            this.handleLandscapeFlipFoley();
         }
         else
         {
            _loc3_ = Math.abs(this.camPan - _loc1_);
            _loc4_ = Math.abs(this.camZoom - 1);
            _loc5_ = Math.max(_loc3_ / this.panDist,_loc4_);
            _loc6_ = this.panDuration * Math.max(1,_loc5_);
            if(_loc6_ > 0)
            {
               this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_INPUT_DISABLE));
               this.panWaiting = true;
               TweenMax.to(this,this.panDuration,{
                  "camPan":_loc1_,
                  "camZoom":1,
                  "ease":Quad.easeInOut,
                  "onComplete":this.panInComplete
               });
            }
            else
            {
               this.panWaiting = false;
            }
         }
         if(!this.panWaiting)
         {
            this.panInComplete();
         }
      }
      
      private function panInComplete() : void
      {
         this.panWaiting = false;
         this.handleCameraReady();
      }
      
      private function handleCameraReady() : void
      {
         var _loc1_:Number = NaN;
         if(!this.panWaiting)
         {
            this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_ZOOM_RESET));
            this.sceneView.dispatchEvent(new Event(SceneViewSprite.EVENT_INPUT_ENABLE));
            this.convo.handleCursorAudioCmds();
            if(this.camera)
            {
               this._attemptCamPan = this.camPan;
               this.camera.drift.anchor = new Point(this.camPan,0);
               if(REPORT_NARROW)
               {
                  _loc1_ = 10;
                  if(Math.abs(this.camera.drift.anchor.x - this.camPan) > _loc1_)
                  {
                     this.logger.error("ConvoView scene too narrow.  Attempt (mark=" + this.transMarkFacing + ") to pan to " + this.camPan + " but got clamped to " + this.camera.drift.anchor.x + " too narrow by " + Math.abs(this.camera.drift.anchor.x - this.camPan));
                  }
               }
            }
         }
         if(this.panWaiting)
         {
         }
      }
      
      private function refreshCamera() : void
      {
         if(!this.camera || !this.camera.drift)
         {
            return;
         }
         if(this.panWaiting)
         {
            return;
         }
         this.camera.drift.anchor = new Point(this._attemptCamPan,0);
      }
      
      public function start() : void
      {
         if(this.started)
         {
            throw new IllegalOperationError("already started");
         }
         this.camera = this.sceneView.scene._camera;
         if(DISABLE_CONVO_ZOOM_FOR_CONSOLE)
         {
            Camera.ALLOW_ZOOM = false;
         }
         this.showConvoNode();
      }
   }
}
