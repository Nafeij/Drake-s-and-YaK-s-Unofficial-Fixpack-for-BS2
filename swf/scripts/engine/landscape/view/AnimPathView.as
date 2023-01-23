package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.landscape.def.AnimPathNodeAlphaDef;
   import engine.landscape.def.AnimPathNodeDef;
   import engine.landscape.def.AnimPathNodeFloatDef;
   import engine.landscape.def.AnimPathNodeHideDef;
   import engine.landscape.def.AnimPathNodeMoveDef;
   import engine.landscape.def.AnimPathNodePlayingDef;
   import engine.landscape.def.AnimPathNodeRotateDef;
   import engine.landscape.def.AnimPathNodeScaleDef;
   import engine.landscape.def.AnimPathNodeSoundDef;
   import engine.landscape.def.AnimPathNodeWaitDef;
   import engine.landscape.def.AnimPathNodeWobbleDef;
   import engine.landscape.def.LandscapeAnimPathDef;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.math.MathUtil;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class AnimPathView
   {
       
      
      public var container:DisplayObjectWrapper;
      
      public var sprite:DisplayObjectWrapper;
      
      public var spriteDef:LandscapeSpriteDef;
      
      public var animPathDef:LandscapeAnimPathDef;
      
      public var playing:Boolean = false;
      
      public var shouldBePlaying:Boolean = true;
      
      private var _wasPlaying:Boolean = false;
      
      private var _showing:Boolean = true;
      
      public var logger:ILogger;
      
      private var landscapeView:LandscapeViewBase;
      
      private var _viewNodes:Vector.<AnimPathViewNode>;
      
      private var _timeSinceStart_ms:int;
      
      private var _loopTime_ms:int;
      
      private var _loopDuration_ms:int;
      
      private var _tempMatrix:Matrix;
      
      private var _updateMatrix:Matrix;
      
      private var _anchorPoint:Point;
      
      public var maxNextDelta:int = 2147483647;
      
      public function AnimPathView(param1:LandscapeViewBase, param2:LandscapeAnimPathDef, param3:DisplayObjectWrapper, param4:LandscapeSpriteDef, param5:DisplayObjectWrapper, param6:ILogger)
      {
         this._tempMatrix = new Matrix();
         this._updateMatrix = new Matrix();
         this._anchorPoint = new Point();
         super();
         this.container = param3;
         this.animPathDef = param2;
         this.sprite = param5;
         this.logger = param6;
         this.landscapeView = param1;
         this.spriteDef = param4;
         this.reset();
         this.checkShowing();
      }
      
      public function reset() : void
      {
         var _loc3_:AnimPathNodeDef = null;
         var _loc4_:AnimPathViewNode = null;
         this._loopDuration_ms = 0;
         if(this.spriteDef._offset)
         {
            this._anchorPoint.setTo(this.spriteDef._offset.x,this.spriteDef._offset.y);
            this.sprite.x = this.spriteDef._offset.x;
            this.sprite.y = this.spriteDef._offset.y;
         }
         this.sprite.rotationDegrees = this.spriteDef.rotation;
         this.sprite.scaleX = this.spriteDef.scaleX;
         this.sprite.scaleY = this.spriteDef.scaleY;
         this.sprite.alpha = 1;
         if(this.animPathDef == null || this.animPathDef.nodes == null)
         {
            throw new ArgumentError("Missing Animpath node defs");
         }
         this._viewNodes = new Vector.<AnimPathViewNode>();
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.animPathDef.nodes.length)
         {
            _loc3_ = this.animPathDef.nodes[_loc2_];
            if(_loc3_.startTimeSecs == -1)
            {
               _loc3_.startTimeSecs = _loc1_;
               if(_loc3_ is AnimPathNodeMoveDef)
               {
                  _loc1_ += (_loc3_ as AnimPathNodeMoveDef).durationSecs;
               }
               else if(_loc3_ is AnimPathNodeWaitDef)
               {
                  _loc1_ += (_loc3_ as AnimPathNodeWaitDef).durationSecs;
               }
               else if(_loc3_ is AnimPathNodeAlphaDef)
               {
                  _loc1_ += (_loc3_ as AnimPathNodeAlphaDef).durationSecs;
               }
            }
            _loc4_ = this._ctorNode(_loc3_);
            if(_loc4_ != null)
            {
               this._loopDuration_ms = Math.max(this._loopDuration_ms,(_loc3_.startTimeSecs + _loc3_.durationSecs) * 1000);
               this._viewNodes.push(_loc4_);
            }
            _loc2_++;
         }
         this.calculateStartTime();
      }
      
      private function calculateStartTime() : void
      {
         var _loc1_:AnimPathViewNode = null;
         var _loc2_:AnimPathNodeDef = null;
         if(this._viewNodes.length)
         {
            if(this.animPathDef.start_segment >= 0 && this.animPathDef.start_segment < this._viewNodes.length && this.animPathDef.start_t > 0)
            {
               _loc1_ = this._viewNodes[this.animPathDef.start_segment];
               _loc2_ = _loc1_.nodeDef;
               this._timeSinceStart_ms = _loc2_.startTimeSecs * 1000;
               this._timeSinceStart_ms += this.animPathDef.start_t * _loc2_.durationSecs * 1000;
               this._loopTime_ms = this._timeSinceStart_ms;
               this.maxNextDelta = (1 - this.animPathDef.start_t) * _loc2_.durationSecs * 1000;
            }
            else
            {
               _loc1_ = this._viewNodes[0];
               this.maxNextDelta = (_loc1_.nodeDef.startTimeSecs + _loc1_.nodeDef.durationSecs) * 1000;
            }
         }
         else
         {
            this.maxNextDelta = 0;
         }
      }
      
      private function _ctorNode(param1:AnimPathNodeDef) : AnimPathViewNode
      {
         var _loc2_:AnimPathViewNode = null;
         if(param1 is AnimPathNodeHideDef)
         {
            _loc2_ = new AnimPathView_Hide(param1 as AnimPathNodeHideDef,this);
         }
         else if(param1 is AnimPathNodeMoveDef)
         {
            _loc2_ = new AnimPathView_Move(param1 as AnimPathNodeMoveDef,this);
         }
         else if(param1 is AnimPathNodeFloatDef)
         {
            _loc2_ = new AnimPathView_Float(param1 as AnimPathNodeFloatDef,this);
         }
         else if(param1 is AnimPathNodeRotateDef)
         {
            _loc2_ = new AnimPathView_Rotate(param1 as AnimPathNodeRotateDef,this);
         }
         else if(param1 is AnimPathNodeWaitDef)
         {
            _loc2_ = new AnimPathView_Wait(param1 as AnimPathNodeWaitDef,this);
         }
         else if(param1 is AnimPathNodeScaleDef)
         {
            _loc2_ = new AnimPathView_Scale(param1 as AnimPathNodeScaleDef,this);
         }
         else if(param1 is AnimPathNodePlayingDef)
         {
            _loc2_ = new AnimPathView_Playing(param1 as AnimPathNodePlayingDef,this);
         }
         else if(param1 is AnimPathNodeAlphaDef)
         {
            _loc2_ = new AnimPathView_Alpha(param1 as AnimPathNodeAlphaDef,this);
         }
         else if(param1 is AnimPathNodeSoundDef)
         {
            _loc2_ = new AnimPathView_Sound(param1 as AnimPathNodeSoundDef,this);
         }
         else if(param1 is AnimPathNodeWobbleDef)
         {
            _loc2_ = new AnimPathView_Wobble(param1 as AnimPathNodeWobbleDef,this);
         }
         return _loc2_;
      }
      
      public function update(param1:int) : void
      {
         if(!this.playing)
         {
            return;
         }
         while(param1 > 0 && this.playing)
         {
            param1 = this._updateFragment(param1);
         }
      }
      
      private function _updateFragment(param1:int) : int
      {
         var _loc4_:AnimPathViewNode = null;
         var _loc5_:AnimPathNodeDef = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         if(param1 > this.maxNextDelta)
         {
            _loc2_ = param1 - this.maxNextDelta;
            param1 = this.maxNextDelta;
         }
         this.maxNextDelta = int.MAX_VALUE;
         this._updateMatrix.identity();
         this._updateMatrix.scale(this.spriteDef.scaleX,this.spriteDef.scaleY);
         this._updateMatrix.rotate(this.spriteDef.rotation * MathUtil.PI_OVER_180);
         this._loopTime_ms += param1;
         this._timeSinceStart_ms += param1;
         var _loc3_:int = 0;
         while(_loc3_ < this._viewNodes.length)
         {
            _loc4_ = this._viewNodes[_loc3_];
            _loc5_ = _loc4_.nodeDef;
            _loc6_ = _loc4_.nodeDef.continuous ? this._timeSinceStart_ms : this._loopTime_ms;
            this._tempMatrix = _loc4_.evaluate(_loc6_);
            if(this._tempMatrix)
            {
               this._updateMatrix.concat(this._tempMatrix);
            }
            if(_loc6_ >= _loc5_.startTimeSecs * 1000)
            {
               _loc7_ = (_loc5_.startTimeSecs + _loc5_.durationSecs) * 1000;
               if(_loc6_ < _loc7_)
               {
                  if(!_loc5_.continuous)
                  {
                     this.maxNextDelta = Math.min(this.maxNextDelta,_loc7_ - _loc6_);
                  }
               }
            }
            _loc3_++;
         }
         this.checkPlaying();
         this._updateMatrix.translate(this._anchorPoint.x,this._anchorPoint.y);
         this.sprite.transformMatrix = this._updateMatrix;
         if(this._loopTime_ms >= this._loopDuration_ms)
         {
            this.loopAnimPath();
            this.playing = this.animPathDef.looping;
         }
         return _loc2_;
      }
      
      private function loopAnimPath() : void
      {
         this._loopTime_ms %= this._loopDuration_ms;
         this.shouldBePlaying = true;
         this._wasPlaying = false;
         var _loc1_:int = 0;
         while(_loc1_ < this._viewNodes.length)
         {
            this._viewNodes[_loc1_].reset();
            _loc1_++;
         }
      }
      
      public function updateAnchor(param1:Number, param2:Number) : void
      {
         this._anchorPoint.setTo(param1,param2);
      }
      
      public function cleanup() : void
      {
         this.showing = false;
         this.container = null;
         this.sprite = null;
         this.animPathDef = null;
      }
      
      public function get showing() : Boolean
      {
         return this._showing;
      }
      
      public function set showing(param1:Boolean) : void
      {
         this._showing = param1;
         this.checkShowing();
      }
      
      private function checkShowing() : void
      {
         if(!this.animPathDef.manage_visibility)
         {
            return;
         }
         if(!this._showing)
         {
            this.sprite.animStop();
         }
         this.sprite.visible = this._showing && this.landscapeView.showPaths;
      }
      
      private function checkPlaying() : void
      {
         if(this.shouldBePlaying)
         {
            this.sprite.animResume(this._wasPlaying);
            this._wasPlaying = true;
         }
      }
      
      public function play() : void
      {
         if(this.playing)
         {
            return;
         }
         if(this.animPathDef.nodes.length == 0)
         {
            return;
         }
         this.playing = true;
         if(this.sprite)
         {
            this.sprite.visible = true;
         }
      }
      
      public function pause() : void
      {
         if(!this.playing)
         {
            return;
         }
         this.playing = false;
         if(this.sprite)
         {
            this.sprite.animStop();
         }
      }
      
      public function restart() : void
      {
         this.pause();
         this._wasPlaying = false;
         this._loopTime_ms = 0;
         this._timeSinceStart_ms = 0;
         this.calculateStartTime();
      }
   }
}
