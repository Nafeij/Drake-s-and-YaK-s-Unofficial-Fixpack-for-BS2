package engine.battle.behavior
{
   import engine.anim.def.AnimClipDef;
   import engine.anim.view.AnimController;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import flash.utils.getTimer;
   
   public class WalkTilesAnimBehavior extends WalkTilesBehavior
   {
       
      
      protected var startTime:Number = 0;
      
      public function WalkTilesAnimBehavior(param1:IBattleEntity)
      {
         super(param1);
      }
      
      override public function start(param1:IBattleMove, param2:Function) : void
      {
         super.start(param1,param2);
         entity.mobility.moving = true;
         this.startTime = getTimer();
         t = 0;
      }
      
      override protected function stop(param1:String) : void
      {
         if(stopped)
         {
            return;
         }
         super.stop(param1);
      }
      
      override public function update(param1:int) : void
      {
         var _loc2_:IBattleEntity = entity;
         if(!_loc2_ || !_loc2_.board || _loc2_.cleanedup || !_loc2_.alive || _loc2_.board.cleanedup)
         {
            return;
         }
         if(!_move)
         {
            return;
         }
         if(stopped)
         {
            return;
         }
         var _loc3_:AnimController = _loc2_.animController;
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Number = _move.numSteps > 0 ? _move.numSteps - 1 : 0;
         var _loc5_:Number = _loc3_.popAccumulatedMovement();
         var _loc6_:Number = t + _loc5_;
         var _loc7_:int = getTimer();
         var _loc8_:int = _loc7_ - this.startTime;
         var _loc9_:Boolean = false;
         var _loc10_:Number = 5000 + _loc4_ * 500 * AnimClipDef.playbackMod;
         if(_loc8_ > _loc10_)
         {
            fastForward();
            return;
         }
         t = _loc6_;
         if(_loc2_ && _loc2_.alive && _loc2_.animController == _loc3_)
         {
            _loc3_.remainingDistance = remainingDistance;
         }
      }
   }
}
