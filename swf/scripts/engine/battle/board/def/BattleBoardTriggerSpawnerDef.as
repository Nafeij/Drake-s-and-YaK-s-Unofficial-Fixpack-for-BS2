package engine.battle.board.def
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.tile.TileLocationVars;
   import engine.tile.TileRectVars;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   
   public class BattleBoardTriggerSpawnerDef
   {
      
      public static const schema:Object = {
         "name":"BattleBoardTriggerSpawner",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "def_id":{
               "type":"string",
               "optional":true
            },
            "trigger_id":{
               "type":"string",
               "optional":true
            },
            "location":{
               "type":TileLocationVars.schema,
               "optional":true
            },
            "facing":{
               "type":"string",
               "optional":true
            },
            "disabled":{
               "type":"boolean",
               "optional":true
            },
            "rect":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var def_id:String;
      
      public var trigger_id:String;
      
      public var rect:TileRect;
      
      public var triggerDef:BattleBoardTriggerDef;
      
      public var triggerSpawnerDefs:BattleBoardTriggerSpawnerDefs;
      
      public var disabled:Boolean;
      
      public function BattleBoardTriggerSpawnerDef()
      {
         super();
      }
      
      public function toString() : String
      {
         return "def_id=" + this.def_id + " trigger_id=" + this.trigger_id + " rect=" + this.rect;
      }
      
      public function clone() : BattleBoardTriggerSpawnerDef
      {
         var _loc1_:BattleBoardTriggerSpawnerDef = new BattleBoardTriggerSpawnerDef();
         return _loc1_.copyFrom(this);
      }
      
      public function copyFrom(param1:BattleBoardTriggerSpawnerDef, param2:Boolean = true) : BattleBoardTriggerSpawnerDef
      {
         this.disabled = param1.disabled;
         this.def_id = param1.def_id;
         this.trigger_id = param1.trigger_id;
         if(param2)
         {
            this.rect = param1.rect.clone();
         }
         return this;
      }
      
      public function resizeTrigger(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.resize(param1,param2,param3,param4))
         {
            this.triggerSpawnerDefs.notifyTriggerSpawnerRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function moveTrigger(param1:int, param2:int) : Boolean
      {
         if(this.rect.translate(param1,param2))
         {
            this.triggerSpawnerDefs.notifyTriggerSpawnerRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setTriggerSize(param1:int, param2:int) : Boolean
      {
         if(this.rect.setSize(param1,param2))
         {
            this.triggerSpawnerDefs.notifyTriggerSpawnerRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setTriggerRect(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.setRect(param1,param2,param3,param4))
         {
            this.triggerSpawnerDefs.notifyTriggerSpawnerRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function setTriggerEdges(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         if(this.rect.setEdges(param1,param2,param3,param4))
         {
            this.triggerSpawnerDefs.notifyTriggerSpawnerRectChanged(this);
            return true;
         }
         return false;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerSpawnerDef
      {
         var _loc4_:TileLocation = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.disabled = param1.disabled;
         var _loc3_:BattleBoardTriggerSpawnerDef = this;
         _loc3_.def_id = param1.def_id;
         if(!_loc3_.def_id)
         {
            _loc3_.def_id = param1.id;
            if(_loc3_.def_id)
            {
            }
         }
         _loc3_.trigger_id = param1.trigger_id;
         if(param1.rect)
         {
            this.rect = TileRectVars.parseString(param1.rect,param2);
         }
         else
         {
            if(!param1.location)
            {
               throw new IllegalOperationError("Requires a rect or location property");
            }
            _loc4_ = TileLocationVars.parse(param1.location,param2);
            this.rect = new TileRect(_loc4_,1,1);
         }
         if(param1.facing)
         {
            this.rect.facing = Enum.parse(BattleFacing,param1.facing) as BattleFacing;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         _loc1_.rect = TileRectVars.saveString(this.rect);
         _loc1_.def_id = !!this.def_id ? this.def_id : "";
         if(this.disabled)
         {
            _loc1_.disabled = this.disabled;
         }
         if(this.trigger_id)
         {
            _loc1_.trigger_id = this.trigger_id;
         }
         if(this.rect.facing)
         {
            _loc1_.facing = this.rect.facing.name;
         }
         return _loc1_;
      }
   }
}
