package engine.saga.action
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleMove;
   import engine.entity.def.IEntityDef;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaInstance;
   import engine.tile.def.TileLocation;
   
   public class Action_BattleUnitMove extends Action
   {
       
      
      private var entity:IBattleEntity;
      
      private var cameraFollowing:Boolean;
      
      public function Action_BattleUnitMove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      public static function parseTilesList(param1:String, param2:Saga) : Vector.<TileLocation>
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:TileLocation = null;
         var _loc13_:String = null;
         var _loc3_:Vector.<TileLocation> = new Vector.<TileLocation>();
         var _loc4_:Array = param1.split(":");
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_)
            {
               _loc6_ = _loc5_.charAt(0);
               if(_loc6_ == "@")
               {
                  _loc7_ = _loc5_.charAt(1);
                  if(_loc7_ == "+")
                  {
                     _loc13_ = _loc5_.substring(2);
                     _loc13_ = param2.performStringReplacement_SagaVar(_loc13_);
                     _parseTriggerId(_loc13_,_loc3_);
                  }
                  else
                  {
                     _loc8_ = _loc5_.substring(1);
                     _loc9_ = _loc8_.split(",");
                     if(_loc9_.length != 2)
                     {
                        throw new ArgumentError("Malformed tile [" + _loc5_ + "] in path [" + param1 + "]");
                     }
                     _loc10_ = int(_loc9_[0]);
                     _loc11_ = int(_loc9_[1]);
                     _loc12_ = TileLocation.fetch(_loc10_,_loc11_);
                     _loc3_.push(_loc12_);
                  }
               }
            }
         }
         return _loc3_;
      }
      
      private static function _parseTriggerId(param1:String, param2:Vector.<TileLocation>) : void
      {
         var _loc3_:ISaga = SagaInstance.instance;
         var _loc4_:IBattleBoard = !!_loc3_ ? _loc3_.getIBattleBoard() : null;
         if(!_loc4_)
         {
            return;
         }
         var _loc5_:IBattleBoardTrigger = _loc4_.triggers.getTriggerByUniqueIdOrId(param1);
         if(!_loc5_)
         {
            throw new ArgumentError("no such trigger spawner [" + param1 + "]");
         }
         _loc5_.rect.collectEnclosedTileLocations(param2);
      }
      
      public static function parseMovementTiles(param1:String, param2:Saga) : Vector.<Vector.<TileLocation>>
      {
         var _loc5_:String = null;
         var _loc6_:Vector.<TileLocation> = null;
         var _loc3_:Vector.<Vector.<TileLocation>> = new Vector.<Vector.<TileLocation>>();
         var _loc4_:Array = param1.split(";");
         for each(_loc5_ in _loc4_)
         {
            _loc6_ = parseTilesList(_loc5_,param2);
            _loc3_.push(_loc6_);
         }
         return _loc3_;
      }
      
      override protected function handleEnded() : void
      {
         var _loc1_:BattleBoardView = null;
         if(this.entity)
         {
            _loc1_ = BattleBoardView.instance;
            if(_loc1_)
            {
               if(this.cameraFollowing && !def.instant)
               {
                  _loc1_.cameraStopFollowingEntity(this.entity);
               }
            }
         }
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         var _loc2_:IEntityDef = saga.getCastMember(_loc1_);
         if(_loc2_)
         {
            _loc1_ = _loc2_.id;
         }
         var _loc3_:Boolean = Boolean(def.param) && def.param.indexOf("camera") >= 0;
         var _loc4_:Boolean = Boolean(def.param) && def.param.indexOf("follow") >= 0;
         var _loc5_:Boolean = !def.param || def.param.indexOf("limited") < 0;
         var _loc6_:Boolean = Boolean(def.param) && def.param.indexOf("pathfind") >= 0;
         this.performMovement(_loc1_,def.anchor,_loc3_,_loc4_,_loc5_,_loc6_);
      }
      
      protected function performMovement(param1:String, param2:String, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean) : void
      {
         var _loc7_:Vector.<Vector.<TileLocation>> = null;
         param1 = saga.performStringReplacement_SagaVar(param1);
         if(param2)
         {
            _loc7_ = parseMovementTiles(param2,saga);
            if(param6)
            {
               this.entity = saga.performBattleUnitPathfind(param1,_loc7_,param5,def.instant ? null : this.moveCompleteHandler);
            }
            else
            {
               this.entity = saga.performBattleUnitMove(param1,_loc7_,param5,def.instant ? null : this.moveCompleteHandler);
            }
            if(def.instant)
            {
               if(!ended)
               {
                  this.handleEntityCamera(param3,param4);
                  end();
               }
               return;
            }
            this.handleEntityCamera(param3,param4);
         }
         else
         {
            this.handleEntityCamera(param3,param4);
            end();
         }
      }
      
      private function handleEntityCamera(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:BattleBoardView = null;
         if(this.entity)
         {
            _loc3_ = BattleBoardView.instance;
            if(param2)
            {
               this.cameraFollowing = true;
               _loc3_.cameraFollowEntity(this.entity,false);
            }
            else if(param1)
            {
               _loc3_.centerOnEntity(this.entity);
               _loc3_.board.scene.disableStartPan();
            }
         }
      }
      
      private function moveCompleteHandler(param1:BattleMove) : void
      {
         end();
      }
   }
}
