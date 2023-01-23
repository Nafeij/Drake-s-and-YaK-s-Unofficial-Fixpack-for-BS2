package engine.battle.ability.effect.op.model
{
   import engine.anim.view.AnimController;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.entity.def.EntityDef;
   import engine.entity.def.IAbilityAssetBundle;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class Op_SpawnUnit extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_SpawnUnit",
         "properties":{
            "id":{"type":"string"},
            "ability":{
               "type":"string",
               "optional":true
            },
            "location":{"type":"string"},
            "party":{
               "type":"string",
               "optional":true
            },
            "despawn":{
               "type":"boolean",
               "optional":true
            },
            "abilityOnRemove":{
               "type":"string",
               "optional":true
            },
            "abilityOnKilled":{
               "type":"string",
               "optional":true
            },
            "expireOnKilled":{
               "type":"boolean",
               "optional":true
            },
            "renownCasterLimit":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static var LOC_EDGE:String = "EDGE";
      
      public static var LOC_TILE:String = "TILE";
       
      
      private var saga:Saga;
      
      private var ed:EntityDef;
      
      private var id:String;
      
      private var location:String;
      
      private var abldef:BattleAbilityDef;
      
      private var abldefOnRemove:BattleAbilityDef;
      
      private var abldefOnKilled:BattleAbilityDef;
      
      private var renownCasterLimit:Boolean = true;
      
      private var expireOnKilled:Boolean;
      
      private var _partyId:String = "npc";
      
      public var ent:BattleEntity;
      
      private var despawn:Boolean = false;
      
      public function Op_SpawnUnit(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         this.id = param1.params.id;
         this.location = param1.params.location;
         this.despawn = BooleanVars.parse(param1.params.despawn,this.despawn);
         this.renownCasterLimit = BooleanVars.parse(param1.params.renownCasterLimit,this.renownCasterLimit);
         var _loc3_:String = param1.params.ability;
         if(_loc3_)
         {
            this.abldef = manager.factory.fetch(_loc3_) as BattleAbilityDef;
         }
         var _loc4_:String = param1.params.abilityOnRemove;
         if(_loc4_)
         {
            this.abldefOnRemove = manager.factory.fetch(_loc4_) as BattleAbilityDef;
         }
         var _loc5_:String = param1.params.abilityOnKilled;
         if(_loc5_)
         {
            this.abldefOnKilled = manager.factory.fetch(_loc5_) as BattleAbilityDef;
         }
         this.expireOnKilled = param1.params.expireOnKilled;
         this.saga = param2.ability.caster.board.scene.context.saga as Saga;
         if(this.saga)
         {
            if(this.id)
            {
               this.ed = this.saga.def.cast.getEntityDefById(this.id) as EntityDef;
               if(!this.ed)
               {
                  logger.error(this.toString() + " no such entity [" + this.id + "]");
               }
               else if(!this.ed.entityClass.mobile)
               {
                  this._partyId = "prop";
               }
            }
         }
         if(param1.params.party)
         {
            this._partyId = param1.params.party;
         }
      }
      
      public static function getEdgeLocation(param1:IBattleBoard, param2:IEntityDef, param3:TileRect, param4:ILogger) : TileLocation
      {
         var _loc5_:int = param2.entityClass.bounds.width;
         var _loc6_:Vector.<Tile> = param1.tiles.collectEdges(null,_loc5_,true);
         if(!_loc6_ || _loc6_.length == 0)
         {
            param4.error("Op_SpawnUnit.getEdgeLocation No valid edges");
            return null;
         }
         var _loc7_:int = param1.scene.context.rng.nextMinMax(0,_loc6_.length - 1);
         return _loc6_[_loc7_].location;
      }
      
      public static function getTileLocation(param1:IBattleEntity, param2:IBattleBoard, param3:IEntityDef, param4:Tile, param5:ILogger) : TileLocation
      {
         var _loc7_:Tile = null;
         var _loc8_:ITileResident = null;
         var _loc9_:ITileResident = null;
         var _loc10_:BattleEntity = null;
         var _loc6_:int = param3.entityClass.bounds.width;
         if(!param2.tiles.canFit(param4.x,param4.y,_loc6_,true))
         {
            param5.info("Op_SpawnUnit.getTileLocation: Entity does not fit at " + param4.x + "," + param4.y + " size " + _loc6_);
            _loc7_ = param2.tiles.getTile(param4.x,param4.y);
            if(!_loc7_)
            {
               param5.error("Op_SpawnUnit.getTileLocation: No tile at " + param4.x + "," + param4.y);
            }
            else if(_loc7_.numResidents > 0)
            {
               param5.info("Op_SpawnUnit.getTileLocation: Tile at " + param4.x + "," + param4.y + " has " + _loc7_.numResidents + " residents.");
               for each(_loc8_ in _loc7_.residents)
               {
                  _loc9_ = _loc7_.residents[_loc8_];
                  if(_loc9_ is BattleEntity)
                  {
                     _loc10_ = _loc9_ as BattleEntity;
                     param5.info("Op_SpawnUnit: Tile resident is " + _loc10_.id + " (class " + _loc10_.def.entityClass.id + ")");
                     if(param1)
                     {
                        param1.notifyCollision(_loc10_);
                     }
                  }
                  else
                  {
                     param5.info("Op_SpawnUnit: resident is not a battle entity (?): " + _loc9_);
                  }
               }
            }
            return null;
         }
         return param4.location;
      }
      
      public static function preloadAssets(param1:EffectDefOp, param2:IAbilityAssetBundle) : void
      {
         var _loc3_:String = param1.params.id;
         if(!_loc3_)
         {
            param2.logger.error("No id on spawn op? " + param1);
         }
         else
         {
            param2.preloadEntityById(_loc3_);
         }
      }
      
      override public function remove() : void
      {
         var _loc1_:BattleAbility = null;
         if(!this.ent)
         {
            return;
         }
         this.ent.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         if(this.despawn)
         {
            this.ent.active = false;
            this.ent._deathAnim = "despawn";
            this.ent._deathVocalization = null;
            this.ent.alive = false;
         }
         if(Boolean(this.abldefOnRemove) && Boolean(manager))
         {
            _loc1_ = new BattleAbility(this.ent,this.abldefOnRemove,manager);
            _loc1_.targetSet.addTarget(this.ent);
            _loc1_.execute(null);
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         var board:IBattleBoard;
         var facing:BattleFacing;
         var entityId:String;
         var deployment:String;
         var partyType:BattlePartyType;
         var timer:int;
         var bfsm:IBattleFsm;
         var ac:AnimController;
         var spawnloc:TileLocation = null;
         var isAlly:Boolean = false;
         var spawnTile:Tile = null;
         var party:IBattleParty = null;
         var partyName:String = null;
         var team:String = null;
         var abl:BattleAbility = null;
         if(!this.id || !this.ed || fake)
         {
            return;
         }
         board = effect.ability.caster.board;
         switch(this.location)
         {
            case LOC_EDGE:
               spawnloc = getEdgeLocation(board,this.ed,caster.rect,logger);
               break;
            case LOC_TILE:
               spawnloc = getTileLocation(caster,board,this.ed,!!tile ? tile : target.tile,logger);
         }
         if(!spawnloc)
         {
            logger.info("Op_SpawnUnit no spawnLoc, skipping");
            return;
         }
         facing = null;
         if(ability.def.targetRule == BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER)
         {
            spawnTile = board.tiles.getTileByLocation(spawnloc);
            facing = BattleAbilityValidation.findValidFacingFor1x2(caster,spawnTile);
         }
         else
         {
            facing = BattleFacing.findFacing(Number(caster.x) - spawnloc.x,Number(caster.y) - spawnloc.y);
         }
         if(!facing)
         {
            logger.error("Op_SpawnUnit unable to find valid facing");
            return;
         }
         entityId = null;
         deployment = null;
         partyType = BattlePartyType.AI;
         timer = 0;
         try
         {
            party = board.getPartyById(this._partyId);
            if(party)
            {
               partyType = party.type;
            }
            partyName = !!party ? party.id : null;
            team = !!party ? party.team : null;
            this.ent = board.addPartyMember(partyName,entityId,this._partyId,team,deployment,this.ed,partyType,timer,isAlly,facing,spawnloc,true) as BattleEntity;
            if(Boolean(this.abldefOnKilled) || this.expireOnKilled)
            {
               this.ent.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
            }
         }
         catch(e:Error)
         {
            logger.error("Op_SpawnUnit failed to add party member " + this + ":\n" + e.getStackTrace());
         }
         if(!this.ent)
         {
            logger.error("Op_SpawnUnit unable to create entity");
            return;
         }
         if(this.renownCasterLimit && this.ent.mobile)
         {
            this.ent.spawnedCasterRenownLimit = true;
         }
         this.ent.spawnedCaster = caster;
         this.ent.deploymentReady = true;
         bfsm = board.fsm;
         if(party && party.id != "prop" && this.ent.mobile)
         {
            bfsm.order.addEntity(this.ent);
            bfsm.participants.push(this.ent);
         }
         ac = this.ent.animController;
         if(Boolean(ac.library) && ac.library.hasOrientedAnims(ac.layer,"spawn"))
         {
            ac.playAnim("spawn",1);
         }
         if(this.abldef)
         {
            abl = new BattleAbility(this.ent,this.abldef,manager);
            abl.targetSet.addTarget(this.ent);
            effect.ability.addChildAbility(abl);
         }
      }
      
      private function aliveHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:BattleAbility = null;
         if(!this.ent)
         {
            return;
         }
         if(this.ent.alive)
         {
            return;
         }
         this.ent.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         if(this.abldefOnKilled)
         {
            _loc2_ = new BattleAbility(caster,this.abldefOnKilled,manager);
            _loc2_.targetSet.addTarget(this.ent);
            logger.info("Op_SpawnUnit killed " + this.ent + " cast " + _loc2_ + " for " + this);
            ability.addChildAbility(_loc2_);
         }
         if(this.expireOnKilled)
         {
            logger.info("Op_SpawnUnit killed " + this.ent + " FORCE EXPIRE " + this);
            effect.forceExpiration();
         }
      }
   }
}
