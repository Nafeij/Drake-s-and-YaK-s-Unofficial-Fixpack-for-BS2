package engine.battle.board.def
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.saga.ISagaExpression;
   import engine.stat.model.Stats;
   import engine.tile.def.TileLocation;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleSpawnerDef extends EventDispatcher
   {
      
      public static const EVENT_LOCATION:String = "BattleSpawnerDef.EVENT_LOCATION";
       
      
      protected var _location:TileLocation;
      
      public var character:String;
      
      public var entityClassId:String;
      
      public var tags:String;
      
      public var facing:BattleFacing;
      
      public var team:String;
      
      public var prop:Boolean = false;
      
      public var isAlly:Boolean;
      
      public var stats:Stats;
      
      public var requireParty:Boolean;
      
      public var requireRoster:Boolean;
      
      public var appearanceIndex:int;
      
      public var deactivateUnit:Boolean;
      
      public var disableUnit:Boolean;
      
      public var deactivateSpawner:Boolean;
      
      public var id:String;
      
      public var ifCondition:String;
      
      public var notCondition:String;
      
      public var index:int;
      
      public var usabilityDef:UsabilityDef;
      
      public var ambientMixAnim:String;
      
      public var shitlistId:String;
      
      public function BattleSpawnerDef()
      {
         this._location = TileLocation.fetch(0,0);
         this.facing = BattleFacing.SE;
         super();
         this.stats = new Stats(null,false);
      }
      
      public function clone() : BattleSpawnerDef
      {
         var _loc1_:BattleSpawnerDef = new BattleSpawnerDef();
         _loc1_.id = this.id;
         _loc1_._location = this._location;
         _loc1_.character = this.character;
         _loc1_.entityClassId = this.entityClassId;
         _loc1_.tags = this.tags;
         _loc1_.facing = this.facing;
         _loc1_.team = this.team;
         _loc1_.prop = this.prop;
         _loc1_.isAlly = this.isAlly;
         _loc1_.stats = this.stats.clone(null);
         _loc1_.requireParty = this.requireParty;
         _loc1_.requireRoster = this.requireRoster;
         _loc1_.appearanceIndex = this.appearanceIndex;
         _loc1_.deactivateUnit = this.deactivateUnit;
         _loc1_.disableUnit = this.disableUnit;
         _loc1_.deactivateSpawner = this.deactivateSpawner;
         _loc1_.ifCondition = this.ifCondition;
         _loc1_.notCondition = this.notCondition;
         _loc1_.ambientMixAnim = this.ambientMixAnim;
         _loc1_.shitlistId = this.shitlistId;
         if(this.usabilityDef)
         {
            _loc1_.usabilityDef = this.usabilityDef.clone();
         }
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return this.labelString;
      }
      
      public function get labelString() : String
      {
         var _loc1_:String = (!!this.character ? this.character : this.entityClassId) + " v" + this.appearanceIndex;
         var _loc2_:String = !!this.tags ? this.tags : "";
         return this.team + " " + _loc1_ + " " + _loc2_;
      }
      
      public function get location() : TileLocation
      {
         return this._location;
      }
      
      public function set location(param1:TileLocation) : void
      {
         if(this._location == param1)
         {
            return;
         }
         this._location = param1;
         dispatchEvent(new Event(EVENT_LOCATION));
      }
      
      public function findSpawnerEntityClass(param1:IEntityListDef, param2:EntityClassDefList) : IEntityClassDef
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:EntityClassDefList = null;
         if(Boolean(this.character) && Boolean(param1))
         {
            _loc3_ = param1.getEntityDefById(this.character);
            return !!_loc3_ ? _loc3_.entityClass : null;
         }
         if(Boolean(this.entityClassId) && Boolean(param2))
         {
            _loc4_ = param2;
            return _loc4_.fetch(this.entityClassId);
         }
         return null;
      }
      
      public function findSpawnerEntityDef(param1:IEntityListDef) : IEntityDef
      {
         var _loc2_:IEntityDef = null;
         if(Boolean(this.character) && Boolean(param1))
         {
            return param1.getEntityDefById(this.character);
         }
         return null;
      }
      
      public function checkConditions(param1:ISagaExpression, param2:ILogger) : Boolean
      {
         if(param1)
         {
            if(this.ifCondition)
            {
               if(!param1.evaluate(this.ifCondition,true))
               {
                  if(param2.isDebugEnabled)
                  {
                     param2.debug("BattleSpawnerDef.checkConditions skip " + this + " ifCondition [" + this.ifCondition + "]");
                  }
                  return false;
               }
            }
            if(this.notCondition)
            {
               if(param1.evaluate(this.notCondition,true))
               {
                  if(param2.isDebugEnabled)
                  {
                     param2.debug("BattleSpawnerDef.checkConditions skip " + this + " notCondition [" + this.notCondition + "]");
                  }
                  return false;
               }
            }
         }
         return true;
      }
   }
}
