package engine.battle.board.def
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.wave.def.BattleWavesDef;
   import engine.core.util.StringUtil;
   import engine.landscape.def.ILandscapeDef;
   import engine.landscape.def.ILandscapeLayerDef;
   import engine.scene.def.ISceneDef;
   import engine.sound.ISoundDriver;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileLocationArea;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class BattleBoardDef extends EventDispatcher
   {
      
      public static const EVENT_POS:String = "BattleBoardDef.EVENT_POS";
      
      public static const EVENT_DEPLOYMENTS:String = "BattleBoardDef.EVENT_DEPLOYMENTS";
      
      public static const EVENT_SPAWNERS:String = "BattleBoardDef.EVENT_SPAWNERS";
       
      
      public var id:String;
      
      protected var _pos:Point;
      
      public var layer:String;
      
      public var deploymentAreas:Vector.<BattleDeploymentArea>;
      
      private var deploymentAreasById:Dictionary;
      
      public var spawners:Vector.<BattleSpawnerDef>;
      
      public var triggerSpawners:BattleBoardTriggerSpawnerDefs;
      
      public var walkableTiles:TileLocationArea;
      
      public var unwalkableTiles:TileLocationArea;
      
      private var resolveCallback:Function;
      
      public var sceneDef:ISceneDef;
      
      public var passivesPlayer:Array;
      
      public var passivesEnemy:Array;
      
      public var passivesPlayer_defs:Vector.<IBattleAbilityDef>;
      
      public var passivesEnemy_defs:Vector.<IBattleAbilityDef>;
      
      public var waves:BattleWavesDef;
      
      public var attractors:BattleAttractorsDef;
      
      public var triggerDefs:BattleBoardTriggerDefList;
      
      public var triggerDefs_global:BattleBoardTriggerDefList;
      
      public var vfxlibUrl:String;
      
      public var soundlibUrl:String;
      
      public function BattleBoardDef(param1:ISceneDef)
      {
         this.deploymentAreas = new Vector.<BattleDeploymentArea>();
         this.deploymentAreasById = new Dictionary();
         this.spawners = new Vector.<BattleSpawnerDef>();
         super();
         this.sceneDef = param1;
      }
      
      override public function toString() : String
      {
         return this.id;
      }
      
      public function cleanup() : void
      {
         this.sceneDef = null;
         this._pos = null;
         this.deploymentAreas = null;
         this.deploymentAreasById = null;
         this.spawners = null;
         if(this.triggerDefs)
         {
            this.triggerDefs.cleanup();
            this.triggerDefs = null;
         }
         this.triggerDefs_global = null;
         if(this.triggerSpawners)
         {
            this.triggerSpawners.cleanup();
            this.triggerSpawners = null;
         }
         this.unwalkableTiles = null;
         this.walkableTiles = null;
      }
      
      public function init() : void
      {
         this.pos = new Point();
         this.layer = "3_walk_back";
         this.walkableTiles = new TileLocationArea();
         this.unwalkableTiles = new TileLocationArea();
      }
      
      public function clone() : BattleBoardDef
      {
         var _loc2_:BattleDeploymentArea = null;
         var _loc3_:BattleSpawnerDef = null;
         var _loc1_:BattleBoardDef = new BattleBoardDef(this.sceneDef);
         _loc1_.init();
         _loc1_.pos.copyFrom(this.pos);
         _loc1_.layer = this.layer;
         _loc1_.walkableTiles = this.walkableTiles.clone();
         _loc1_.unwalkableTiles = this.unwalkableTiles.clone();
         for each(_loc2_ in this.deploymentAreas)
         {
            _loc1_.addDeploymentArea(_loc2_.clone());
         }
         for each(_loc3_ in this.spawners)
         {
            _loc1_.addSpawner(_loc3_.clone());
         }
         if(this.triggerDefs)
         {
            _loc1_.triggerDefs = this.triggerDefs.clone();
         }
         if(this.triggerDefs)
         {
            _loc1_.triggerDefs = this.triggerDefs.clone();
         }
         if(this.attractors)
         {
            _loc1_.attractors = this.attractors.clone();
         }
         return _loc1_;
      }
      
      public function resolve(param1:Function, param2:ISoundDriver) : void
      {
         if(this.resolveCallback != null)
         {
            throw IllegalOperationError("already resolving");
         }
         this.resolveCallback = param1;
         this.finishResolve(param2);
      }
      
      private function finishResolve(param1:ISoundDriver) : void
      {
         var _loc2_:Function = this.resolveCallback;
         if(_loc2_ != null)
         {
            _loc2_(this,param1);
         }
      }
      
      public function addDeploymentArea(param1:BattleDeploymentArea) : void
      {
         if(param1.id in this.deploymentAreasById)
         {
            throw new ArgumentError("Already have deployment area " + param1.id);
         }
         this.deploymentAreasById[param1.id] = param1;
         this.deploymentAreas.push(param1);
      }
      
      public function getDeploymentSizeById(param1:String) : int
      {
         var _loc3_:BattleDeploymentArea = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.deploymentAreas)
         {
            if(StringUtil.startsWith(_loc3_.id,param1))
            {
               _loc2_ += _loc3_.area.numTiles;
            }
         }
         return _loc2_;
      }
      
      public function getDeploymentAreasById(param1:String, param2:BattleDeploymentAreas) : BattleDeploymentAreas
      {
         var _loc4_:BattleDeploymentArea = null;
         if(!param2)
         {
            param2 = new BattleDeploymentAreas();
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.deploymentAreas.length)
         {
            _loc4_ = this.deploymentAreas[_loc3_];
            if(StringUtil.startsWith(_loc4_.id,param1))
            {
               param2.addDeployment(_loc4_);
            }
            _loc3_++;
         }
         param2.area.fit();
         return param2;
      }
      
      public function getDeploymentAreaById(param1:String) : BattleDeploymentArea
      {
         return this.deploymentAreasById[param1];
      }
      
      public function getDeploymentAreaIdByIndex(param1:int) : String
      {
         param1 %= this.deploymentAreas.length;
         return this.deploymentAreas[param1].id;
      }
      
      public function getDeploymentFacing(param1:String) : BattleFacing
      {
         var _loc2_:BattleDeploymentArea = this.getDeploymentAreaById(param1);
         return !!_loc2_ ? _loc2_.facing : null;
      }
      
      public function addSpawner(param1:BattleSpawnerDef) : void
      {
         param1.index = this.spawners.length;
         this.spawners.push(param1);
      }
      
      public function get pos() : Point
      {
         return this._pos;
      }
      
      public function set pos(param1:Point) : void
      {
         if(this._pos == param1)
         {
            return;
         }
         if(Boolean(this._pos) && Boolean(param1))
         {
            if(this._pos.x == param1.x && this._pos.y == param1.y)
            {
               return;
            }
         }
         this._pos = param1;
         dispatchEvent(new Event(EVENT_POS));
      }
      
      public function createDeploymentArea() : BattleDeploymentArea
      {
         var _loc2_:String = null;
         var _loc3_:BattleDeploymentArea = null;
         var _loc1_:int = 0;
         while(_loc1_ < 100)
         {
            _loc2_ = "New Board " + _loc1_;
            if(!this.getDeploymentAreaById(_loc2_))
            {
               _loc3_ = new BattleDeploymentArea();
               this.deploymentAreas.push(_loc3_);
               this.deploymentAreasById[this.id] = _loc3_;
               dispatchEvent(new Event(EVENT_DEPLOYMENTS));
               return _loc3_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function promoteDeploymentArea(param1:BattleDeploymentArea) : void
      {
         var _loc2_:int = this.deploymentAreas.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.deploymentAreas.splice(_loc2_,1);
            this.deploymentAreas.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new Event(EVENT_DEPLOYMENTS));
         }
      }
      
      public function demoteDeploymentArea(param1:BattleDeploymentArea) : void
      {
         var _loc2_:int = this.deploymentAreas.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.deploymentAreas.length - 1)
         {
            this.deploymentAreas.splice(_loc2_,1);
            this.deploymentAreas.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new Event(EVENT_DEPLOYMENTS));
         }
      }
      
      public function removeDeploymentArea(param1:BattleDeploymentArea) : void
      {
         var _loc2_:int = this.deploymentAreas.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.deploymentAreas.splice(_loc2_,1);
            dispatchEvent(new Event(EVENT_DEPLOYMENTS));
         }
      }
      
      public function renameDeploymentArea(param1:BattleDeploymentArea, param2:String) : void
      {
         var _loc3_:int = this.deploymentAreas.indexOf(param1);
         if(_loc3_ >= 0)
         {
            delete this.deploymentAreasById[param1.id];
            param1.id = param2;
            this.deploymentAreas[param1.id] = param1;
            dispatchEvent(new Event(EVENT_DEPLOYMENTS));
         }
      }
      
      public function createSpawnerDef() : BattleSpawnerDef
      {
         var _loc1_:BattleSpawnerDef = new BattleSpawnerDef();
         _loc1_.team = "npc";
         this.spawners.push(_loc1_);
         dispatchEvent(new Event(EVENT_SPAWNERS));
         return _loc1_;
      }
      
      public function promoteSpawnerDef(param1:BattleSpawnerDef) : void
      {
         var _loc2_:int = this.spawners.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.spawners.splice(_loc2_,1);
            this.spawners.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new Event(EVENT_SPAWNERS));
         }
      }
      
      public function demoteSpawnerDef(param1:BattleSpawnerDef) : void
      {
         var _loc2_:int = this.spawners.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.spawners.length - 1)
         {
            this.spawners.splice(_loc2_,1);
            this.spawners.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new Event(EVENT_SPAWNERS));
         }
      }
      
      public function removeSpawnerDef(param1:BattleSpawnerDef) : void
      {
         var _loc2_:int = this.spawners.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.spawners.splice(_loc2_,1);
            dispatchEvent(new Event(EVENT_SPAWNERS));
         }
      }
      
      public function getFirstSpawnerAt(param1:TileLocation) : BattleSpawnerDef
      {
         var _loc2_:BattleSpawnerDef = null;
         for each(_loc2_ in this.spawners)
         {
            if(_loc2_.location == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getFirstDeploymentAreaAt(param1:TileLocation) : BattleDeploymentArea
      {
         var _loc2_:BattleDeploymentArea = null;
         for each(_loc2_ in this.deploymentAreasById)
         {
            if(_loc2_.area.hasTile(param1))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function hasSpawnerAt(param1:TileLocation) : Boolean
      {
         return this.getFirstSpawnerAt(param1) != null;
      }
      
      public function computeBoundary() : Rectangle
      {
         var _loc1_:Rectangle = new Rectangle();
         if(this.walkableTiles)
         {
            _loc1_ = _loc1_.union(this.walkableTiles.computeBoundary());
         }
         if(this.unwalkableTiles)
         {
            _loc1_ = _loc1_.union(this.unwalkableTiles.computeBoundary());
         }
         var _loc2_:int = 64;
         var _loc3_:int = 32;
         _loc1_.width *= _loc2_;
         _loc1_.height *= _loc3_;
         _loc1_.x *= _loc2_;
         _loc1_.y *= _loc3_;
         _loc1_.x += this._pos.x;
         _loc1_.y += this._pos.y;
         var _loc4_:ILandscapeDef = !!this.sceneDef ? this.sceneDef.landscape : null;
         var _loc5_:ILandscapeLayerDef = !!_loc4_ ? _loc4_.getLayer(this.layer) : null;
         var _loc6_:Point = !!_loc5_ ? _loc5_.getOffset() : null;
         if(_loc6_)
         {
            _loc1_.x += _loc6_.x;
            _loc1_.y += _loc6_.y;
         }
         return _loc1_;
      }
      
      public function getSpawnerById(param1:String) : BattleSpawnerDef
      {
         var _loc2_:BattleSpawnerDef = null;
         for each(_loc2_ in this.spawners)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function hasTile(param1:TileLocation) : Boolean
      {
         return this.walkableTiles.hasTile(param1) || this.unwalkableTiles.hasTile(param1);
      }
      
      public function getTriggerDefById(param1:String) : BattleBoardTriggerDef
      {
         var _loc2_:BattleBoardTriggerDef = null;
         _loc2_ = !!this.triggerDefs ? this.triggerDefs.getDefById(param1) : null;
         if(!_loc2_)
         {
            _loc2_ = !!this.triggerDefs_global ? this.triggerDefs_global.getDefById(param1) : null;
         }
         return _loc2_;
      }
   }
}
