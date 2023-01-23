package engine.battle.board.model
{
   import engine.ability.def.StringIntPair;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.def.BattleDeploymentAreas;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.math.Rng;
   import engine.saga.Saga;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import engine.tile.def.TileRect;
   import flash.geom.Point;
   
   public class BattleDeployer_Saga
   {
       
      
      private var board:IBattleBoard;
      
      private var logger:ILogger;
      
      public var saga:Saga;
      
      public var rng:Rng;
      
      private var wa:Array;
      
      private var unfriendlies:Vector.<TileLocation>;
      
      public function BattleDeployer_Saga(param1:IBattleBoard)
      {
         this.wa = [];
         super();
         this.board = param1;
         this.logger = param1.logger;
         this.saga = param1.scene.context.saga as Saga;
         this.rng = param1.scene.context.rng;
      }
      
      public function autoDeployParty(param1:IBattleParty, param2:Boolean, param3:Boolean) : void
      {
         var _loc11_:IBattleEntity = null;
         if(!param1)
         {
            return;
         }
         if(param1.numMembers == 0)
         {
            this.logger.error("BattleDeployer_Saga.autoDeployParty " + this.board.toDebugString() + " cannot autodeploy empty party [" + param1 + "]");
            return;
         }
         var _loc4_:BattleDeploymentAreas = new BattleDeploymentAreas();
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < param1.numMembers)
         {
            _loc11_ = param1.getMember(_loc6_);
            if(_loc11_.alive && Boolean(_loc11_.enabled) && Boolean(_loc11_.active) && !_loc11_.deploymentReady)
            {
               _loc5_++;
            }
            _loc6_++;
         }
         if(!_loc5_)
         {
            return;
         }
         if(!param1.deployment)
         {
            this.logger.error("BattleDeployer_Saga.autoDeployParty " + this.board.toDebugString() + " no deployment area available for party " + param1 + ", numUndeployed=" + _loc5_);
            return;
         }
         _loc4_ = this.board.def.getDeploymentAreasById(param1.deployment,_loc4_);
         if(!_loc4_.numDeployments)
         {
            this.logger.error("BattleDeployer_Saga.autoDeployParty " + this.board.toDebugString() + " cannot autodeploy non-existent area(s): [" + param1.deployment + "]");
            return;
         }
         var _loc7_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc8_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc9_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc10_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         this.subdivideUnits(param1,_loc7_,_loc8_,_loc9_,_loc10_,param2);
         this.internal_deploys(_loc4_,_loc7_,_loc8_,_loc9_,_loc10_,param3);
      }
      
      private function subdivideUnits(param1:IBattleParty, param2:Vector.<IBattleEntity>, param3:Vector.<IBattleEntity>, param4:Vector.<IBattleEntity>, param5:Vector.<IBattleEntity>, param6:Boolean) : void
      {
         var _loc8_:IBattleEntity = null;
         var _loc7_:int = 0;
         while(_loc7_ < param1.numMembers)
         {
            _loc8_ = param1.getMember(_loc7_);
            if(!_loc8_.deploymentReady)
            {
               if(param6 && !_loc8_.def.attacks.getAbilityDefById("abl_melee_str"))
               {
                  if(_loc8_.isLocalRect(1,1))
                  {
                     param4.push(_loc8_);
                  }
                  else
                  {
                     param5.push(_loc8_);
                  }
               }
               else if(_loc8_.isLocalRect(1,1))
               {
                  param2.push(_loc8_);
               }
               else
               {
                  param3.push(_loc8_);
               }
            }
            _loc7_++;
         }
      }
      
      private function deploySomeUnits(param1:Vector.<IBattleEntity>, param2:TileLocation, param3:BattleDeploymentAreas, param4:Boolean, param5:Boolean) : void
      {
         var _loc6_:IBattleEntity = null;
         if(!param1 || param1.length == 0)
         {
            return;
         }
         if(param4)
         {
            param3.area.sortByRow(param2,param5);
            ArrayUtil.shuffleTight(param3.area.sorted,10,this.rng);
         }
         for each(_loc6_ in param1)
         {
            this.autoDeployCharacterToAreas(_loc6_,param3);
         }
      }
      
      private function internal_deploys(param1:BattleDeploymentAreas, param2:Vector.<IBattleEntity>, param3:Vector.<IBattleEntity>, param4:Vector.<IBattleEntity>, param5:Vector.<IBattleEntity>, param6:Boolean) : void
      {
         var _loc7_:Point = this.board.def.walkableTiles.rect.center;
         var _loc8_:TileLocation = TileLocation.fetch(_loc7_.x,_loc7_.y);
         param1.area.resetSorted();
         if(!param6)
         {
            ArrayUtil.shuffle(param1.area.sorted,this.rng);
         }
         this.deploySomeUnits(param3,_loc8_,param1,param6,true);
         this.deploySomeUnits(param5,_loc8_,param1,param6,false);
         this.deploySomeUnits(param2,_loc8_,param1,param6,true);
         this.deploySomeUnits(param4,_loc8_,param1,param6,false);
      }
      
      public function autoDeployCharacterToAreas(param1:IBattleEntity, param2:BattleDeploymentAreas) : Boolean
      {
         var _loc5_:TileLocation = null;
         var _loc6_:BattleFacing = null;
         var _loc7_:StringIntPair = null;
         var _loc8_:int = 0;
         var _loc9_:TileLocation = null;
         if(Boolean(this.unfriendlies) && Boolean(this.unfriendlies.length))
         {
            this.unfriendlies.splice(0,this.unfriendlies.length);
         }
         var _loc3_:TileRect = param1.rect.clone();
         var _loc4_:int = 0;
         while(_loc4_ < param2.area.sorted.length)
         {
            _loc5_ = param2.area.sorted[_loc4_];
            _loc3_.setLocation(_loc5_);
            _loc6_ = param2.getLocationFacing(_loc5_);
            _loc3_.facing = _loc6_;
            if(!this._isLocationFriendly(_loc3_,param2.area))
            {
               if(!this.unfriendlies)
               {
                  this.unfriendlies = new Vector.<TileLocation>();
               }
               this.unfriendlies.push(_loc5_);
            }
            else if(this.board.deploy.attemptDeployRect(param1,param2.area,_loc3_))
            {
               if(!param1.tile)
               {
                  this.logger.error("Problem deploying. no tile for: " + param1 + " at loc " + _loc5_);
                  return false;
               }
               param2.area.removeSortedRect(_loc3_);
               param1.facing = _loc6_;
               _loc7_ = param2.getExecAbilityId(_loc5_);
               if(_loc7_)
               {
                  param1.executeEntityAbilityId(_loc7_.id,_loc7_.value);
               }
               return true;
            }
            _loc4_++;
         }
         if(this.unfriendlies)
         {
            _loc8_ = 0;
            while(_loc8_ < this.unfriendlies.length)
            {
               _loc9_ = this.unfriendlies[_loc8_];
               _loc3_.setLocation(_loc9_);
               _loc6_ = param2.getLocationFacing(_loc9_);
               _loc3_.facing = _loc6_;
               if(this.board.deploy.attemptDeployRect(param1,param2.area,_loc3_))
               {
                  if(!param1.tile)
                  {
                     this.logger.error("Problem deploying. no tile for: " + param1 + " at loc " + _loc9_);
                     return false;
                  }
                  param2.area.removeSortedRect(_loc3_);
                  param1.facing = _loc6_;
                  return true;
               }
               _loc8_++;
            }
         }
         return false;
      }
      
      private function probeEdge(param1:int, param2:int, param3:TileLocationArea, param4:int, param5:int) : int
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:TileLocation = null;
         var _loc6_:int = 1;
         while(_loc6_ < 30)
         {
            _loc7_ = param1 + _loc6_ * param4;
            _loc8_ = param2 + _loc6_ * param5;
            _loc9_ = TileLocation.fetch(_loc7_,_loc8_);
            if(!param3.hasTile(_loc9_))
            {
               return _loc6_ - 1;
            }
            _loc6_++;
         }
         return 0;
      }
      
      private function _isLocationFriendly(param1:TileRect, param2:TileLocationArea) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:* = false;
         var _loc16_:* = false;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:* = false;
         var _loc20_:* = false;
         var _loc5_:Boolean = true;
         var _loc6_:int = param1.left;
         var _loc7_:int = param1.right;
         var _loc8_:int = param1.front;
         var _loc9_:int = param1.back;
         var _loc10_:int = param1.width;
         var _loc11_:int = param1.length;
         if(_loc10_ > 1)
         {
            _loc13_ = 10000;
            _loc14_ = 10000;
            _loc4_ = _loc8_;
            while(_loc4_ < _loc9_)
            {
               _loc13_ = Math.min(_loc13_,this.probeEdge(_loc6_,_loc4_,param2,-1,0));
               _loc14_ = Math.min(_loc14_,this.probeEdge(_loc7_,_loc4_,param2,1,0));
               _loc15_ = _loc13_ % _loc10_ == 0;
               _loc16_ = _loc14_ % _loc10_ == 0;
               _loc5_ = _loc15_ || _loc16_;
               if(!_loc5_)
               {
                  break;
               }
               _loc4_++;
            }
         }
         var _loc12_:Boolean = true;
         if(_loc11_ > 1)
         {
            _loc17_ = 10000;
            _loc18_ = 10000;
            _loc3_ = _loc6_;
            while(_loc3_ < _loc7_)
            {
               _loc17_ = Math.min(_loc17_,this.probeEdge(_loc3_,_loc8_,param2,0,-1));
               _loc18_ = Math.min(_loc18_,this.probeEdge(_loc3_,_loc9_,param2,0,1));
               _loc19_ = _loc17_ % _loc11_ == 0;
               _loc20_ = _loc18_ % _loc11_ == 0;
               _loc12_ = _loc19_ || _loc20_;
               if(!_loc12_)
               {
                  break;
               }
               _loc3_++;
            }
         }
         return _loc5_ && _loc12_;
      }
   }
}
