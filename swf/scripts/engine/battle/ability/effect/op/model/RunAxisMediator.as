package engine.battle.ability.effect.op.model
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class RunAxisMediator
   {
       
      
      private const _LOCO_ID:String = "ability_run";
      
      private var move:BattleMove;
      
      private var loco_anim:String = "ability_run";
      
      private var changeFacing:Boolean = true;
      
      private var destinationX:int;
      
      private var destinationY:int;
      
      private var caster:IBattleEntity;
      
      private var target:IBattleEntity;
      
      private var callbackExecuted:Function;
      
      private var callbackInterrupted:Function;
      
      private var callbackIntersected:Function;
      
      private var logger:ILogger;
      
      private var _stopOnIntersect:Boolean;
      
      public function RunAxisMediator(param1:IBattleEntity, param2:IBattleEntity, param3:int, param4:int, param5:String, param6:Boolean, param7:ILogger, param8:Function, param9:Function, param10:Function, param11:Boolean = false)
      {
         super();
         this.destinationX = param3;
         this.destinationY = param4;
         this.loco_anim = param5;
         this.changeFacing = param6;
         this.logger = param7;
         this.caster = param1;
         this.target = param2;
         this.callbackExecuted = param8;
         this.callbackInterrupted = param9;
         this.callbackIntersected = param10;
         this._stopOnIntersect = param11;
         this._setup();
      }
      
      public function cleanup() : void
      {
         this.removeListeners();
         if(this.move)
         {
            this.move.cleanup();
            this.move = null;
         }
         this.caster = null;
         this.target = null;
         this.callbackExecuted = null;
         this.callbackInterrupted = null;
         this.callbackIntersected = null;
      }
      
      private function _setup() : void
      {
         var _loc6_:Tile = null;
         var _loc7_:TileRect = null;
         var _loc8_:int = 0;
         this.move = new BattleMove(this.caster,0);
         this.move.forcedMove = true;
         this.move.reactToEntityIntersect = true;
         this.move.changeFacing = this.changeFacing;
         var _loc1_:* = this.caster.y == this.destinationY;
         var _loc2_:int = _loc1_ ? this.destinationX - Number(this.caster.x) : this.destinationY - Number(this.caster.y);
         var _loc3_:int = _loc2_ > 0 ? 1 : -1;
         var _loc4_:int = _loc3_;
         while(_loc2_ != 0)
         {
            _loc6_ = null;
            if(_loc1_)
            {
               _loc6_ = this.caster.board.tiles.getTile(this.caster.x + _loc4_,this.caster.y);
            }
            else
            {
               _loc6_ = this.caster.board.tiles.getTile(this.caster.x,this.caster.y + _loc4_);
            }
            this.move.addStep(_loc6_);
            _loc4_ += _loc3_;
            _loc2_ -= _loc3_;
         }
         var _loc5_:TileRect = this.caster.rect;
         if(this.target)
         {
            _loc7_ = this.target.rect;
            _loc8_ = TileRectRange.computeRange(_loc5_,_loc7_);
            _loc8_ = Math.max(0,_loc8_ - 1);
            this.caster.stats.setBase(StatType.RUNTHROUGH_DISTANCE,_loc8_);
         }
         else
         {
            this.caster.stats.setBase(StatType.RUNTHROUGH_DISTANCE,_loc2_);
         }
         this.addListeners();
      }
      
      public function start() : void
      {
         this.move.setCommitted("Op_RunThrough.apply");
         this.caster.mobility.executeMove(this.move);
      }
      
      private function addListeners() : void
      {
         this.caster.locoId = this.loco_anim;
         this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         this.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         this.move.addEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
      }
      
      private function removeListeners() : void
      {
         if(this.caster.locoId == this.loco_anim)
         {
            this.caster.locoId = null;
         }
         if(this.move)
         {
            this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            this.move.removeEventListener(BattleMoveEvent.INTERSECT_ENTITY,this.moveIntersectEntityHandler);
         }
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         this.removeListeners();
         this.callbackExecuted(this);
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         this.removeListeners();
         this.callbackInterrupted(this);
      }
      
      private function moveIntersectEntityHandler(param1:BattleMoveEvent) : void
      {
         this.logger.info(">>>> INTERSECTING " + this.caster.tile + " mv=" + param1.mv);
         if(this._stopOnIntersect)
         {
            this.removeListeners();
         }
         this.callbackIntersected(this,param1.other);
      }
   }
}
