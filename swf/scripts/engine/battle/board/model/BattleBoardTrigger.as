package engine.battle.board.model
{
   import engine.ability.IAbilityDef;
   import engine.anim.def.IAnimFacing;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.phantasm.def.VfxSequenceDefs;
   import engine.battle.board.def.BattleBoardTriggerDef;
   import engine.battle.board.def.BattleBoardTriggerResponseDef;
   import engine.battle.board.def.ITileTriggerDef;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaInstance;
   import engine.saga.SagaVar;
   import engine.tile.Tile;
   import engine.tile.TileTrigger;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class BattleBoardTrigger extends TileTrigger implements IBattleBoardTrigger
   {
      
      private static var _last_id_index:int = 0;
       
      
      public var _id:String;
      
      public var _effect:IEffect = null;
      
      protected var entitiesHitThisTurnPerTile:Dictionary;
      
      public var _vfxds:VfxSequenceDefs;
      
      public var _def:BattleBoardTriggerDef;
      
      public var board:IBattleBoard;
      
      public var logger:ILogger;
      
      private var _enabled:Boolean;
      
      private var _turnCount:int = 0;
      
      public var responses:Vector.<BattleBoardTriggerResponse>;
      
      public var _triggerId:String;
      
      public var _triggers:IBattleBoardTriggers;
      
      public var _useCount:int = 0;
      
      private var _displayAbilities:Vector.<IAbilityDef>;
      
      private var _numEnemies:int;
      
      private var _numAllies:int;
      
      private var _numUnits:int;
      
      private var _countsTileConfiguration:int;
      
      private var _fadeAlpha:Number = 1;
      
      public function BattleBoardTrigger(param1:IBattleBoardTriggers, param2:Tiles, param3:String, param4:IBattleBoard, param5:ITileTriggerDef, param6:TileRect, param7:Boolean, param8:IEffect, param9:Boolean)
      {
         var _loc10_:BattleBoardTriggerResponseDef = null;
         var _loc11_:BattleBoardTriggerResponse = null;
         this.entitiesHitThisTurnPerTile = new Dictionary();
         this.responses = new Vector.<BattleBoardTriggerResponse>();
         this._displayAbilities = new Vector.<IAbilityDef>();
         super(param6,param7,callback,param2);
         this._triggers = param1;
         this._triggerId = !!param3 ? param3 : param5.id;
         this._id = param3 + ++_last_id_index;
         this.board = param4;
         this._effect = param8;
         this._def = param5 as BattleBoardTriggerDef;
         if(!this._def)
         {
            throw new ArgumentError("Invalid trigger definition " + param5);
         }
         this._enabled = !param9;
         if(this._def.responses)
         {
            for each(_loc10_ in this._def.responses.responses)
            {
               _loc11_ = new BattleBoardTriggerResponse(this,param4.getAbilityDefFactory(),_loc10_);
               this.responses.push(_loc11_);
               if(_loc11_._displayAbilityDef)
               {
                  this._displayAbilities.push(_loc11_._displayAbilityDef);
               }
            }
         }
         this._vfxds = this._def.vfxds;
         this.logger = param4.logger;
      }
      
      public function get triggers() : IBattleBoardTriggers
      {
         return this._triggers;
      }
      
      public function get triggerId() : String
      {
         return this._triggerId;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(this._enabled == param1)
         {
            return;
         }
         this._enabled = param1;
         this._resetCounts();
         this.logger.i("TRIG","enabled " + param1 + " " + this);
         this._setVar(SagaVar.SUFFIX_ENABLED,this._enabled ? 1 : 0);
         this._triggers.handleTriggerEnabled(this);
      }
      
      public function validate() : void
      {
         var _loc1_:BattleBoardTriggerResponse = null;
         for each(_loc1_ in this.responses)
         {
            _loc1_.validate();
         }
      }
      
      public function get facing() : IAnimFacing
      {
         return !!rect ? rect.facing : null;
      }
      
      public function toString() : String
      {
         var _loc1_:String = callback != null ? " cb" : "";
         return "[" + this._id + "/" + this._def.toString() + _loc1_ + "]@" + rect.toString();
      }
      
      public function intersectsEntity(param1:IBattleEntity) : Boolean
      {
         return rect.testIntersectsRect(param1.rect);
      }
      
      public function intersectsRect(param1:TileRect) : Boolean
      {
         return rect.testIntersectsRect(param1);
      }
      
      public function check(param1:IBattleEntity, param2:TileRect) : Boolean
      {
         var _loc8_:Tile = null;
         var _loc9_:BattleBoardTriggerResponse = null;
         if(param1.alive == false)
         {
            return false;
         }
         var _loc3_:Boolean = rect.testIntersectsRect(param2);
         if(!_loc3_)
         {
            return false;
         }
         var _loc4_:* = "";
         if(this.logger.isDebugEnabled)
         {
            _loc4_ = "BattleBoardTrigger.check " + this + " " + param1 + "@" + param2 + " ";
            param1.logger.debug(_loc4_ + "CHECKING");
         }
         if(this.def.limit > 0 && this._useCount >= this.def.limit)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug(_loc4_ + "SKIP hit limit count [" + this._useCount + "/" + this.def.limit + "]");
            }
            return false;
         }
         var _loc5_:Boolean = false;
         var _loc6_:Vector.<Tile> = this.getTriggeringTiles(param1,param2);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_.length)
         {
            _loc8_ = _loc6_[_loc7_];
            if(!_loc8_)
            {
               if(this.logger.isDebugEnabled)
               {
                  this.logger.debug(_loc4_ + "SKIP bogustile");
               }
               return false;
            }
            for each(_loc9_ in this.responses)
            {
               _loc5_ = _loc9_.checkTriggerResponse(param1,_loc4_,_loc8_) || _loc5_;
               if(!param1.alive || param1.cleanedup)
               {
                  break;
               }
            }
            if(_loc5_)
            {
               ++this._useCount;
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      private function getTriggeringTiles(param1:IBattleEntity, param2:TileRect) : Vector.<Tile>
      {
         var _loc6_:int = 0;
         var _loc7_:Tile = null;
         var _loc8_:Dictionary = null;
         var _loc3_:Vector.<Tile> = new Vector.<Tile>();
         var _loc4_:* = "";
         if(this.logger.isDebugEnabled)
         {
            _loc4_ = "BattleBoardTrigger.check " + this + " " + param1 + "@";
         }
         var _loc5_:int = param2.left;
         while(_loc5_ < param2.right)
         {
            _loc6_ = param2.front;
            while(_loc6_ < param2.back)
            {
               _loc7_ = param1.board.tiles.getTile(_loc5_,_loc6_);
               if(_loc7_ == null)
               {
                  this.logger.error(_loc4_ + "Invalid tile {" + _loc5_ + ", " + _loc6_ + "}");
               }
               if(this.intersectsRect(_loc7_.rect))
               {
                  _loc8_ = this.entitiesHitThisTurnPerTile[_loc7_];
                  if(_loc8_ == null)
                  {
                     this.entitiesHitThisTurnPerTile[_loc7_] = new Dictionary();
                     _loc8_ = this.entitiesHitThisTurnPerTile[_loc7_];
                  }
                  if(_loc8_[param1] != null)
                  {
                     if(this.logger.isDebugEnabled)
                     {
                        this.logger.debug(_loc4_ + "{" + _loc5_ + ", " + _loc6_ + "} SKIP alreadyhit");
                     }
                  }
                  else
                  {
                     _loc8_[param1] = 1;
                     _loc3_.push(_loc7_);
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function pulseCheck(param1:IBattleEntity, param2:TileRect) : Boolean
      {
         if(!this._def.pulse)
         {
            return false;
         }
         return this.check(param1,param2);
      }
      
      public function clearEntitiesHitThisTurn() : void
      {
         this.entitiesHitThisTurnPerTile = new Dictionary();
      }
      
      public function isHazardToEntity(param1:IBattleEntity) : Boolean
      {
         var _loc2_:BattleBoardTriggerResponse = null;
         for each(_loc2_ in this.responses)
         {
            if(_loc2_.isHazardToEntity(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get effect() : IEffect
      {
         return this._effect;
      }
      
      public function get vfxds() : VfxSequenceDefs
      {
         return this._vfxds;
      }
      
      public function get def() : BattleBoardTriggerDef
      {
         return this._def;
      }
      
      public function getDisplayAbilities() : Vector.<IAbilityDef>
      {
         return this._displayAbilities;
      }
      
      public function get numEnemies() : int
      {
         this.checkResetCounts();
         return this._numEnemies;
      }
      
      public function get numAllies() : int
      {
         this.checkResetCounts();
         return this._numAllies;
      }
      
      public function get numUnits() : int
      {
         this.checkResetCounts();
         return this._numUnits;
      }
      
      public function checkResetCounts() : void
      {
         this._countsTileConfiguration != this.board.tileConfiguration && this._resetCounts();
      }
      
      private function _resetCounts() : void
      {
         var _loc1_:IBattleEntity = null;
         this._numEnemies = 0;
         this._numAllies = 0;
         this._numUnits = 0;
         this._countsTileConfiguration = this.board.tileConfiguration;
         if(this._enabled)
         {
            for each(_loc1_ in this.board.entities)
            {
               if(!(!_loc1_.alive || !_loc1_.mobile))
               {
                  if(this.intersectsEntity(_loc1_))
                  {
                     if(_loc1_.isPlayer)
                     {
                        ++this._numAllies;
                     }
                     else if(_loc1_.isEnemy)
                     {
                        ++this._numEnemies;
                     }
                  }
               }
            }
         }
         this._numUnits = this._numEnemies + this._numAllies;
         this._setVar(SagaVar.SUFFIX_NUM_ALLIES,this._numAllies);
         this._setVar(SagaVar.SUFFIX_NUM_ENEMIES,this._numEnemies);
         this._setVar(SagaVar.SUFFIX_NUM_UNITS,this._numUnits);
         this._setVar(SagaVar.SUFFIX_ENABLED,this._enabled ? 1 : 0);
      }
      
      private function _setVar(param1:String, param2:int) : void
      {
         var _loc3_:String = this.triggerId;
         var _loc4_:ISaga = SagaInstance.instance;
         if(_loc4_)
         {
            _loc4_.setVar(SagaVar.PREFIX_BATTLE_TRIGGER + _loc3_ + param1,param2);
         }
      }
      
      private function _removeVar(param1:String) : void
      {
         var _loc2_:String = this.def.id;
         var _loc3_:ISaga = SagaInstance.instance;
         if(_loc3_)
         {
            _loc3_.removeVar(SagaVar.PREFIX_BATTLE_TRIGGER + _loc2_ + param1);
         }
      }
      
      public function clearVars() : void
      {
         this._removeVar(SagaVar.SUFFIX_NUM_ALLIES);
         this._removeVar(SagaVar.SUFFIX_NUM_ENEMIES);
         this._removeVar(SagaVar.SUFFIX_NUM_UNITS);
         this._removeVar(SagaVar.SUFFIX_ENABLED);
      }
      
      public function updateTurnEntity(param1:IBattleEntity) : void
      {
         if(!this._def.incorporeal || !param1)
         {
            this.fadeAlpha = 1;
            return;
         }
         var _loc2_:Number = param1.incorporeal ? 1 : this._def.incorporealFadeAlpha;
         this.fadeAlpha = _loc2_;
      }
      
      public function get fadeAlpha() : Number
      {
         return this._fadeAlpha;
      }
      
      public function set fadeAlpha(param1:Number) : void
      {
         if(this._fadeAlpha == param1)
         {
            return;
         }
         this._fadeAlpha = param1;
      }
      
      public function get expired() : Boolean
      {
         return this.def.duration > 0 ? this._turnCount >= this.def.duration : false;
      }
      
      public function turnCountIncrease(param1:int) : void
      {
         this._turnCount += param1;
      }
   }
}
