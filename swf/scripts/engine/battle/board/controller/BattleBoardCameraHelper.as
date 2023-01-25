package engine.battle.board.controller
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quart;
   import engine.battle.BattleCameraEvent;
   import engine.battle.board.def.BattleDeploymentArea;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.view.EntityView;
   import engine.battle.sim.IBattleParty;
   import engine.core.render.BoundedCamera;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class BattleBoardCameraHelper
   {
       
      
      public var board:BattleBoard;
      
      public var view:BattleBoardView;
      
      public var camera:BoundedCamera;
      
      public function BattleBoardCameraHelper(param1:BattleBoard, param2:BattleBoardView)
      {
         super();
         this.board = param1;
         this.view = param2;
         this.camera = this.board._scene._camera;
         this.AddEventListeners();
      }
      
      private function AddEventListeners() : void
      {
         if(this.board)
         {
            this.board.addEventListener(BattleCameraEvent.CAMERA_SHOW_ALL_ENEMIES,this.cameraShowAllEnemiesHandler);
            this.board.addEventListener(BattleCameraEvent.CAMERA_ZOOM_IN_TO,this.cameraZoomToHandler);
            this.board.addEventListener(BattleCameraEvent.CAMERA_ZOOM_OUT_MAX,this.cameraZoomMaxHandler);
            this.board.addEventListener(BattleCameraEvent.CAMERA_PAN_TO_DEPLOYMENT_AREA,this.cameraPanToDeploymentArea);
            this.board.addEventListener(BattleCameraEvent.CAMERA_CENTER_ON_ISO_POINT,this.cameraCenterOnIsoPoint);
         }
      }
      
      private function RemoveEventListeners() : void
      {
         if(this.board)
         {
            this.board.removeEventListener(BattleCameraEvent.CAMERA_SHOW_ALL_ENEMIES,this.cameraShowAllEnemiesHandler);
            this.board.removeEventListener(BattleCameraEvent.CAMERA_ZOOM_IN_TO,this.cameraZoomToHandler);
            this.board.removeEventListener(BattleCameraEvent.CAMERA_ZOOM_OUT_MAX,this.cameraZoomMaxHandler);
            this.board.removeEventListener(BattleCameraEvent.CAMERA_PAN_TO_DEPLOYMENT_AREA,this.cameraPanToDeploymentArea);
            this.board.removeEventListener(BattleCameraEvent.CAMERA_CENTER_ON_ISO_POINT,this.cameraCenterOnIsoPoint);
         }
      }
      
      public function cleanup() : void
      {
         this.RemoveEventListeners();
      }
      
      public function cameraShowAllEnemiesHandler(param1:BattleCameraEvent) : void
      {
         var _loc2_:IBattleParty = this.board.getPartyById("npc");
         var _loc3_:Vector.<Boolean> = new Vector.<Boolean>();
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.numMembers)
         {
            _loc3_.push(!_loc2_.getMember(_loc4_).alive);
            _loc4_++;
         }
         this.panToNextBatch(Math.min(1.25,BoundedCamera.computeDpiFingerScale()),param1,_loc2_,_loc3_);
      }
      
      public function entityOnScreen(param1:EntityView) : Boolean
      {
         var _loc2_:Rectangle = new Rectangle();
         var _loc3_:Point = param1.centerScreenPointGlobal;
         _loc2_.x = _loc3_.x - param1.width / 2;
         _loc2_.y = _loc3_.y - param1.height / 2;
         _loc2_.height = param1.height;
         _loc2_.width = param1.width;
         if(_loc2_.x < 0 || _loc2_.y < 0)
         {
            return false;
         }
         if(_loc2_.right > this.camera.viewWidth || _loc2_.bottom > this.camera.viewHeight)
         {
            return false;
         }
         return true;
      }
      
      private function panToNextBatch(param1:Number, param2:BattleCameraEvent, param3:IBattleParty, param4:Vector.<Boolean>) : void
      {
         var _loc6_:int = 0;
         if(param2.targetEntity)
         {
            _loc6_ = 0;
            while(_loc6_ < param3.numMembers)
            {
               if(!param4[_loc6_])
               {
                  if(this.entityOnScreen(this.view.getEntityView(param3.getMember(_loc6_))))
                  {
                     param4[_loc6_] = true;
                  }
               }
               _loc6_++;
            }
         }
         param2.targetEntity = this.getClosestUnvisitedVillain(param2.targetEntity,param3,param4);
         if(!param2.targetEntity)
         {
            param2.onComplete();
            return;
         }
         var _loc5_:Point = this.view.getEntityScenePoint(param2.targetEntity);
         TweenMax.killTweensOf(this.camera);
         TweenMax.to(this.camera,param2.duration,{
            "zoom":param1,
            "x":_loc5_.x,
            "y":_loc5_.y,
            "ease":Quart.easeInOut,
            "onComplete":this.delayNextTween,
            "onCompleteParams":[param1,param2,param3,param4]
         });
      }
      
      private function delayNextTween(param1:Number, param2:BattleCameraEvent, param3:IBattleParty, param4:Vector.<Boolean>) : void
      {
         TweenMax.killTweensOf(this.camera);
         TweenMax.to(this.camera,param2.delay,{
            "onComplete":this.panToNextBatch,
            "onCompleteParams":[param1,param2,param3,param4]
         });
      }
      
      private function getClosestUnvisitedVillain(param1:IBattleEntity, param2:IBattleParty, param3:Vector.<Boolean>) : IBattleEntity
      {
         var _loc7_:Number = NaN;
         var _loc8_:IBattleEntity = null;
         var _loc9_:IBattleEntity = null;
         var _loc10_:Number = NaN;
         var _loc4_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc5_:Point = new Point(0,0);
         var _loc6_:int = 0;
         while(_loc6_ < param2.numMembers)
         {
            if(!param3[_loc6_])
            {
               _loc4_.push(param2.getMember(_loc6_));
            }
            _loc6_++;
         }
         if(param1)
         {
            _loc5_ = new Point(param1.x,param1.y);
         }
         for each(_loc9_ in _loc4_)
         {
            _loc10_ = this.getDistanceSq(_loc9_,_loc5_);
            if(_loc8_ == null || _loc10_ < _loc7_)
            {
               _loc7_ = _loc10_;
               _loc8_ = _loc9_;
            }
         }
         return _loc8_;
      }
      
      private function getDistanceSq(param1:IBattleEntity, param2:Point) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      public function cameraZoomMaxHandler(param1:BattleCameraEvent) : void
      {
         var _loc2_:BoundedCamera = this.board._scene._camera;
         var _loc3_:Number = _loc2_.width / _loc2_.maxWidth;
         TweenMax.killTweensOf(_loc2_);
         var _loc4_:Point = this.view.getEntityScenePoint(param1.targetEntity);
         if(!_loc4_)
         {
            _loc4_ = new Point(0,0);
         }
         TweenMax.to(_loc2_,param1.duration,{
            "zoom":_loc3_,
            "x":_loc4_.x,
            "y":_loc4_.y,
            "delay":param1.delay,
            "ease":Quart.easeInOut,
            "onComplete":param1.onComplete
         });
      }
      
      public function cameraZoomToHandler(param1:BattleCameraEvent) : void
      {
         var _loc2_:BoundedCamera = this.board._scene._camera;
         var _loc3_:Number = Math.min(1.25,BoundedCamera.computeDpiFingerScale());
         var _loc4_:Point = this.view.getEntityScenePoint(param1.targetEntity);
         if(!_loc4_)
         {
            _loc4_ = new Point(0,0);
         }
         TweenMax.killTweensOf(_loc2_);
         TweenMax.to(_loc2_,param1.delay,{
            "zoom":_loc3_,
            "x":_loc4_.x,
            "y":_loc4_.y,
            "delay":param1.duration,
            "ease":Quart.easeInOut,
            "onComplete":param1.onComplete
         });
      }
      
      public function cameraPanToDeploymentArea(param1:BattleCameraEvent) : void
      {
         var _loc3_:Point = null;
         var _loc2_:Number = Math.min(1.25,BoundedCamera.computeDpiFingerScale());
         var _loc4_:BattleDeploymentArea = this.board.def.getDeploymentAreaById(param1.targetString);
         var _loc5_:TileRect = _loc4_.area.rect;
         _loc3_ = this.view.getScenePointFromBoardPoint(_loc5_.left + _loc5_.width / 2,_loc5_.front + _loc5_.length / 2);
         TweenMax.killTweensOf(this.camera);
         TweenMax.to(this.camera,param1.duration,{
            "zoom":_loc2_,
            "x":_loc3_.x,
            "y":_loc3_.y,
            "delay":param1.delay,
            "ease":Quart.easeInOut,
            "onComplete":param1.onComplete
         });
      }
      
      private function cameraCenterOnIsoPoint(param1:BattleCameraEvent) : void
      {
         if(!param1.isoPoint)
         {
            throw new ArgumentError("evt must have a loc");
         }
         var _loc2_:BoundedCamera = this.board._scene._camera;
         var _loc3_:Number = 1;
         var _loc4_:Point = this.view.getScenePoint(param1.isoPoint.x,param1.isoPoint.y);
         if(!_loc4_)
         {
            _loc4_ = new Point(0,0);
         }
         TweenMax.killTweensOf(_loc2_);
         TweenMax.to(_loc2_,param1.delay,{
            "zoom":_loc3_,
            "x":_loc4_.x,
            "y":_loc4_.y,
            "delay":param1.duration,
            "ease":Quart.easeInOut,
            "onComplete":param1.onComplete
         });
      }
   }
}
