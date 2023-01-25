package engine.battle.board.view.overlay
{
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.op.model.Op_KnockbackHelper;
   import engine.battle.ability.effect.op.model.Op_RunThroughHelper;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.IsoBattleRectangleUtils;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.EntityLinkedDirtyRenderSprite;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.IBattleTurn;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.MathUtil;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   
   public class AbilityDestinationOverlay extends EntityLinkedDirtyRenderSprite
   {
       
      
      private var arrows:Vector.<DisplayObjectWrapper>;
      
      public function AbilityDestinationOverlay(param1:BattleBoardView)
      {
         this.arrows = new Vector.<DisplayObjectWrapper>();
         super(param1);
         fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.fsmEventHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.fsmEventHandler);
         fsm.addEventListener(BattleFsmEvent.TURN_COMMITTED,this.fsmEventHandler);
         var _loc2_:BattleAssetsDef = view.board.assets;
         view.bitmapPool.addPool(_loc2_.board_move_arrow_special_north,3,16);
         view.bitmapPool.addPool(_loc2_.board_move_arrow_special_south,3,16);
      }
      
      override public function cleanup() : void
      {
         fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.fsmEventHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY_TARGETS,this.fsmEventHandler);
         fsm.removeEventListener(BattleFsmEvent.TURN_COMMITTED,this.fsmEventHandler);
         super.cleanup();
      }
      
      private function removeAllArrows() : void
      {
         var _loc2_:DisplayObjectWrapper = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.arrows.length)
         {
            _loc2_ = this.arrows[_loc1_];
            view.bitmapPool.reclaim(_loc2_);
            _loc1_++;
         }
         displayObjectWrapper.removeAllChildren();
      }
      
      override protected function handleCanRenderChanged() : void
      {
         if(!canRender)
         {
            this.removeAllArrows();
         }
      }
      
      override protected function onRender() : void
      {
         var _loc1_:BattleTurn = null;
         var _loc6_:TileLocation = null;
         var _loc7_:Tile = null;
         var _loc16_:TileLocation = null;
         var _loc17_:DisplayObjectWrapper = null;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Point = null;
         this.removeAllArrows();
         _loc1_ = fsm.turn as BattleTurn;
         var _loc2_:BattleAbility = !!_loc1_ ? _loc1_.ability : null;
         if(!_loc1_ || _loc1_.committed || !_loc2_ || _loc2_.targetSet.targets.length == 0)
         {
            return;
         }
         var _loc3_:IBattleEntity = _loc2_.caster;
         var _loc4_:BattleAbilityTargetRule = _loc2_._def.targetRule;
         var _loc5_:IBattleEntity = _loc2_.targetSet.targets[0];
         var _loc8_:Number = 0.5;
         if(_loc4_ == BattleAbilityTargetRule.SPECIAL_RUN_THROUGH)
         {
            _loc7_ = Op_RunThroughHelper.findLandingTileBehind(_loc3_,_loc3_.rect,_loc5_.rect,true);
            _loc6_ = _loc2_.caster.tile.location;
            _loc8_ = _loc3_.diameter / 2;
         }
         else if(_loc4_ == BattleAbilityTargetRule.SPECIAL_RUN_TO)
         {
            _loc7_ = Op_RunThroughHelper.findLandingTileBefore(_loc3_,_loc3_.rect,_loc5_.rect,true);
            _loc6_ = _loc2_.caster.tile.location;
            _loc8_ = _loc3_.diameter / 2;
         }
         else if(_loc4_ == BattleAbilityTargetRule.SPECIAL_TRAMPLE)
         {
            _loc7_ = Op_RunThroughHelper.findLandingTileBehind(_loc3_,_loc3_.rect,_loc5_.rect,false);
            _loc6_ = _loc2_.caster.tile.location;
            _loc8_ = _loc3_.diameter / 2;
         }
         else
         {
            if(_loc4_ !== BattleAbilityTargetRule.SPECIAL_BATTERING_RAM)
            {
               throw new IllegalOperationError("nope " + _loc4_);
            }
            if(!_loc5_.mobile)
            {
               return;
            }
            _loc7_ = Op_KnockbackHelper.getKnockbackStopTile(_loc2_.def,_loc3_,_loc3_.rect,_loc5_,true);
            _loc6_ = _loc5_.tile.location;
            _loc8_ = _loc5_.diameter / 2;
         }
         var _loc9_:TileLocation = _loc7_.location;
         var _loc10_:int = _loc9_.x - _loc6_.x;
         var _loc11_:int = _loc9_.y - _loc6_.y;
         var _loc12_:int = Math.max(Math.abs(_loc10_),Math.abs(_loc11_));
         var _loc13_:Point = new Point(MathUtil.clampValue(_loc10_,-1,1),MathUtil.clampValue(_loc11_,-1,1));
         var _loc14_:TileLocation = _loc6_;
         var _loc15_:int = 1;
         while(_loc15_ <= _loc12_)
         {
            _loc16_ = TileLocation.fetch(_loc6_.x + _loc13_.x * _loc15_,_loc6_.y + _loc13_.y * _loc15_);
            _loc17_ = this.getArrow(_loc14_,_loc16_);
            displayObjectWrapper.addChild(_loc17_);
            this.arrows.push(_loc17_);
            _loc18_ = (_loc14_.x + _loc16_.x) / 2 + _loc8_;
            _loc19_ = (_loc14_.y + _loc16_.y) / 2 + _loc8_;
            _loc20_ = IsoBattleRectangleUtils.getIsoPointScreenPoint(view.units,_loc18_,_loc19_);
            _loc17_.x = _loc20_.x - _loc17_.scaleX * _loc17_.width / 2;
            _loc17_.y = _loc20_.y - _loc17_.height / 2;
            _loc14_ = _loc16_;
            _loc15_++;
         }
      }
      
      private function getArrow(param1:TileLocation, param2:TileLocation) : DisplayObjectWrapper
      {
         var _loc5_:DisplayObjectWrapper = null;
         var _loc3_:int = param2.x - param1.x;
         var _loc4_:int = param2.y - param1.y;
         if(_loc3_ > 0)
         {
            _loc5_ = view.bitmapPool.pop(view.board.assets.board_move_arrow_special_south);
            _loc5_.scaleX = 1;
         }
         else if(_loc4_ < 0)
         {
            _loc5_ = view.bitmapPool.pop(view.board.assets.board_move_arrow_special_north);
            _loc5_.scaleX = 1;
         }
         else if(_loc4_ > 0)
         {
            _loc5_ = view.bitmapPool.pop(view.board.assets.board_move_arrow_special_south);
            _loc5_.scaleX = -1;
         }
         else if(_loc3_ < 0)
         {
            _loc5_ = view.bitmapPool.pop(view.board.assets.board_move_arrow_special_north);
            _loc5_.scaleX = -1;
         }
         return _loc5_;
      }
      
      private function fsmEventHandler(param1:BattleFsmEvent) : void
      {
         this.checkCanRender();
         setRenderDirty();
      }
      
      override protected function checkCanRender() : void
      {
         var _loc1_:IBattleTurn = null;
         var _loc3_:BattleAbilityTargetRule = null;
         _loc1_ = fsm.turn;
         var _loc2_:BattleAbility = !!_loc1_ ? _loc1_.ability : null;
         if(Boolean(_loc1_) && !_loc1_.committed)
         {
            if(_loc2_)
            {
               _loc3_ = _loc2_._def.targetRule;
               if(_loc3_ === BattleAbilityTargetRule.SPECIAL_BATTERING_RAM || _loc3_ == BattleAbilityTargetRule.SPECIAL_RUN_THROUGH || _loc3_ == BattleAbilityTargetRule.SPECIAL_RUN_TO || _loc3_ == BattleAbilityTargetRule.SPECIAL_TRAMPLE)
               {
                  if(_loc2_.targetSet.targets.length > 0)
                  {
                     canRender = true;
                     return;
                  }
               }
            }
         }
         canRender = false;
      }
   }
}
