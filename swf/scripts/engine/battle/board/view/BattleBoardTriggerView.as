package engine.battle.board.view
{
   import as3isolib.data.INode;
   import as3isolib.display.scene.IsoScene;
   import engine.battle.ability.phantasm.def.VfxSequenceDef;
   import engine.battle.ability.phantasm.model.VfxSequence;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.view.phantasm.VfxSequenceView;
   import engine.battle.entity.view.EntityView;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceManager;
   import engine.tile.def.TileRect;
   import engine.vfx.VfxLibrary;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class BattleBoardTriggerView
   {
       
      
      public var trigger:IBattleBoardTrigger;
      
      public var boardView:BattleBoardView;
      
      public var vfxViews:Dictionary;
      
      public var vfxViewsById:Dictionary;
      
      private var logger:ILogger;
      
      private var smoothing:Boolean;
      
      public var vfxs:Vector.<VfxSequence>;
      
      private var _postLoaded:Boolean;
      
      public var playedOut:Boolean;
      
      private var lib:VfxLibrary;
      
      private var resman:ResourceManager;
      
      public function BattleBoardTriggerView(param1:BattleBoardView, param2:IBattleBoardTrigger, param3:ILogger, param4:Boolean)
      {
         this.vfxViews = new Dictionary();
         this.vfxViewsById = new Dictionary();
         this.vfxs = new Vector.<VfxSequence>();
         super();
         this.trigger = param2;
         this.boardView = param1;
         this.logger = param3;
         this.smoothing = param4;
      }
      
      public function postLoadTriggerView() : void
      {
         if(this._postLoaded)
         {
            throw new IllegalOperationError("double post load");
         }
         this._postLoaded = true;
         this.processVfxds();
      }
      
      public function processVfxds() : void
      {
         this.parseVfxds();
      }
      
      public function update(param1:int) : void
      {
         var _loc3_:VfxSequence = null;
         var _loc4_:VfxSequenceView = null;
         if(!this._postLoaded)
         {
            this.playedOut = false;
            return;
         }
         this.playedOut = true;
         var _loc2_:Number = this.trigger.fadeAlpha;
         for each(_loc3_ in this.vfxs)
         {
            _loc3_.vfxAlpha = _loc2_;
            _loc3_.update(param1);
            if(!_loc3_.complete)
            {
               this.playedOut = false;
            }
         }
         for each(_loc4_ in this.vfxViews)
         {
            _loc4_.update(param1);
         }
      }
      
      public function playOut() : void
      {
         var _loc1_:VfxSequence = null;
         for each(_loc1_ in this.vfxs)
         {
            _loc1_.doEnd();
         }
      }
      
      private function parseVfxds() : void
      {
         var _loc1_:EntityView = null;
         var _loc2_:Boolean = false;
         var _loc3_:VfxSequenceDef = null;
         if(this.trigger.effect)
         {
            _loc1_ = this.boardView.getEntityView(this.trigger.effect.ability.caster);
            this.lib = !!_loc1_ ? _loc1_.theVfxLibrary : null;
         }
         if(!this.lib)
         {
            this.lib = this.boardView.board.vfxLibrary;
         }
         this.resman = this.boardView.board.scene.context.resman;
         if(this.trigger.vfxds)
         {
            for each(_loc3_ in this.trigger.vfxds.vfxds)
            {
               if(!this.lib)
               {
                  this.logger.error("Attempt to create BattleBoardTrigger vfx [" + _loc3_.id + "] with no anim library");
               }
               else
               {
                  if(!_loc2_)
                  {
                     _loc2_ = true;
                  }
                  this._parseVfxSequenceDef(_loc3_,this.resman,this.lib);
               }
            }
         }
      }
      
      private function _parseVfxSequenceDef(param1:VfxSequenceDef, param2:ResourceManager, param3:VfxLibrary) : void
      {
         var _loc4_:TileRect = this.trigger.rect;
         _loc4_.visitEnclosedTileLocations(this._visitRectTile,param1);
      }
      
      private function _visitRectTile(param1:int, param2:int, param3:VfxSequenceDef) : void
      {
         var _loc7_:VfxSequence = null;
         var _loc4_:IsoScene = this.boardView.isoScenes.getIsoScene(param3.depth);
         if(!_loc4_)
         {
            this.logger.error("No such scene depth [" + param3.depth + "] for trigger vfx " + _loc7_);
            return;
         }
         var _loc5_:String = this.trigger.id + "_" + param3.id + "_" + param1 + "_" + param2;
         var _loc6_:INode = _loc4_.getChildByID(_loc5_);
         if(_loc6_)
         {
            throw new IllegalOperationError("invalid duplicate trigger vfx id " + _loc5_);
         }
         _loc7_ = new VfxSequence(param3,this.resman,this.lib,this.logger,0,this.trigger.facing);
         this.vfxs.push(_loc7_);
         if(_loc7_.def.randomize)
         {
            _loc7_.randomize();
         }
         var _loc8_:VfxSequenceView = this.vfxViews[_loc7_] = new VfxSequenceView(_loc7_,this.logger,this.smoothing);
         _loc8_.id = _loc5_;
         this.vfxViewsById[_loc7_.def.id] = _loc8_;
         var _loc9_:Number = this.boardView.units;
         var _loc10_:Number = param1 + 1;
         var _loc11_:Number = param2 + 1;
         var _loc12_:Point = _loc7_.def.offset;
         if(_loc12_)
         {
            _loc10_ += _loc12_.x;
            _loc11_ += _loc12_.y;
         }
         _loc8_.moveTo(_loc10_ * _loc9_,_loc11_ * _loc9_,0);
         _loc4_.addChild(_loc8_);
      }
      
      public function cleanup() : void
      {
         var _loc1_:VfxSequenceView = null;
         var _loc2_:VfxSequence = null;
         for each(_loc1_ in this.vfxViews)
         {
            if(_loc1_.parent)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            _loc1_.cleanup();
         }
         for each(_loc2_ in this.vfxs)
         {
            _loc2_.cleanup();
         }
         this.vfxViews = null;
         this.boardView = null;
         this.trigger = null;
      }
   }
}
