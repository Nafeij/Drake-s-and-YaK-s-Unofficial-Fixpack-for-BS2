package engine.battle.fsm.aimodule
{
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatType;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class AiModuleDredge_Attractor
   {
       
      
      private var _attractorPlansComputed:Boolean;
      
      private var _attractorPlansFound:Boolean;
      
      public var caster:IBattleEntity;
      
      public var moveFlood:IBattleMove;
      
      public var ai:AiModuleBase;
      
      public var logger:ILogger;
      
      public function AiModuleDredge_Attractor(param1:AiModuleBase)
      {
         super();
         this.ai = param1;
         this.caster = param1.caster;
         this.moveFlood = param1.moveFlood;
         this.logger = param1.ss.logger;
         this.caster.discoverAttractor();
      }
      
      private function _checkAttractorPositionOk(param1:IBattleAttractor) : Boolean
      {
         var _loc2_:TileRect = this.caster.rect;
         var _loc3_:Boolean = _loc2_.testIntersectsRect(param1.core);
         var _loc4_:Boolean = !!param1.leash ? _loc2_.testIntersectsRect(param1.leashRect) : _loc3_;
         if(!_loc4_)
         {
            if(this.caster.attractorCoreReached)
            {
               this.logger.i("ATRC","exited leash " + this.caster + " " + param1);
               this.caster.attractorCoreReached = false;
            }
            return false;
         }
         if(this.caster.attractorCoreReached)
         {
            return true;
         }
         if(_loc3_)
         {
            this.logger.i("ATRC","reached core " + this.caster + " " + param1);
            this.caster.attractorCoreReached = true;
            return true;
         }
         return false;
      }
      
      private function _checkAttractorFidgetOk() : Boolean
      {
         if(!this.caster.attractorCoreReached)
         {
            return false;
         }
         return false;
      }
      
      public function checkAttractorAi(param1:Vector.<AiPlan>, param2:int) : Boolean
      {
         var _loc3_:IBattleAttractor = this.caster.attractor;
         if(!_loc3_)
         {
            return false;
         }
         if(this._attractorPlansComputed)
         {
            return false;
         }
         this._attractorPlansComputed = true;
         var _loc4_:TileRect = this.caster.rect;
         if(this._checkAttractorPositionOk(_loc3_))
         {
            return false;
         }
         if(this._checkAttractorFidgetOk())
         {
            return false;
         }
         var _loc5_:IBattleMove = this.moveFlood.clone();
         var _loc6_:int = int(this.caster.stats.getValue(StatType.MOVEMENT));
         var _loc7_:int = _loc6_;
         var _loc8_:int = TileRectRange.computeRange(_loc3_.leashRect,this.caster.rect);
         var _loc9_:int = Math.max(0,_loc8_ - _loc7_);
         var _loc10_:int = _loc6_ + param2;
         if(Boolean(_loc9_) && _loc3_.def.urgent)
         {
            _loc7_ += Math.min(param2,_loc9_);
         }
         if(AiGlobalConfig.DEBUG)
         {
            this.logger.d("ATRC","leashing " + this.caster + " " + _loc3_);
         }
         if(_loc5_.pathTowardRect(_loc3_.core,true,_loc7_,true))
         {
            this.ai.createAttacksOfOpportunity(null,param1,_loc5_,null,0);
            this._attractorPlansFound = true;
         }
         else
         {
            if(!_loc5_.pathTowardRect(_loc3_.leashRect,true,_loc10_,true))
            {
               _loc5_.cleanup();
               return false;
            }
            this.ai.createAttacksOfOpportunity(null,param1,_loc5_,null,0);
            this._attractorPlansFound = true;
         }
         return this._attractorPlansFound;
      }
      
      public function get attractorPlansFound() : Boolean
      {
         return this._attractorPlansFound;
      }
   }
}
