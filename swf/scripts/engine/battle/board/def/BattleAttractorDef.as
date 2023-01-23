package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.tile.TileRectVars;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   
   public class BattleAttractorDef
   {
      
      public static const schema:Object = {
         "name":"BattleAttractorDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "core":{"type":"string"},
            "leash":{
               "type":"number",
               "optional":true
            },
            "enabled":{
               "type":"boolean",
               "optional":true
            },
            "urgent":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var core:TileRect;
      
      public var leash:int;
      
      public var enabled:Boolean;
      
      public var urgent:Boolean;
      
      public var leashRect:TileRect;
      
      public var attractorDefs:BattleAttractorsDef;
      
      public function BattleAttractorDef()
      {
         super();
      }
      
      public function ensureReadyForEditor() : BattleAttractorDef
      {
         if(!this.core)
         {
            this.core = new TileRect(TileLocation.fetch(0,0),1,1);
         }
         return this;
      }
      
      public function copyFrom(param1:BattleAttractorDef) : BattleAttractorDef
      {
         this.id = param1.id;
         this.core = param1.core.clone();
         this.leash = param1.leash;
         this.enabled = param1.enabled;
         this.urgent = param1.urgent;
         return this;
      }
      
      public function get rect() : TileRect
      {
         return this.core;
      }
      
      public function toString() : String
      {
         return "id=" + this.id + ", enabled=" + this.enabled + ", core=" + this.core + ", leash=" + this.leash;
      }
      
      public function clone() : BattleAttractorDef
      {
         var _loc1_:BattleAttractorDef = new BattleAttractorDef();
         _loc1_.id = this.id;
         _loc1_.core = this.core.clone();
         _loc1_.leash = this.leash;
         _loc1_.enabled = this.enabled;
         _loc1_.leashRect = this.leashRect.clone();
         _loc1_.urgent = this.urgent;
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleAttractorDef
      {
         this.id = param1.id;
         this.core = TileRectVars.parseString(param1.core,param2);
         this.leash = param1.leash;
         this.enabled = param1.enabled;
         this.leashRect = this.core.clone();
         this.urgent = param1.urgent;
         if(this.leash)
         {
            this.leashRect.grow(-this.leash,-this.leash).grow(this.leash,this.leash);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "id":this.id,
            "core":TileRectVars.saveString(this.core)
         };
         if(this.enabled)
         {
            _loc1_.enabled = this.enabled;
         }
         if(this.leash)
         {
            _loc1_.leash = this.leash;
         }
         if(this.urgent)
         {
            _loc1_.urgent = this.urgent;
         }
         return _loc1_;
      }
      
      public function resizeAttractor(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.resize(param1,param2,param3,param4))
         {
            this.attractorDefs.notifyAttractorRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function moveAttractor(param1:int, param2:int) : Boolean
      {
         if(this.rect.translate(param1,param2))
         {
            this.attractorDefs.notifyAttractorRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setAttractorSize(param1:int, param2:int) : Boolean
      {
         if(this.rect.setSize(param1,param2))
         {
            this.attractorDefs.notifyAttractorRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setAttractorRect(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.setRect(param1,param2,param3,param4))
         {
            this.attractorDefs.notifyAttractorRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setAttractorEdges(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.setEdges(param1,param2,param3,param4))
         {
            this.attractorDefs.notifyAttractorRectChanged(this);
            return true;
         }
         return false;
      }
   }
}
