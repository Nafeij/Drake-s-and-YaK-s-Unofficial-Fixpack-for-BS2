package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.tile.def.TileLocation;
   import flash.events.EventDispatcher;
   
   public class BattleAttractorsDef extends EventDispatcher
   {
      
      public static const schema:Object = {
         "name":"BattleAttractorsDef",
         "type":"object",
         "properties":{"attractors":{
            "type":"array",
            "items":BattleAttractorDef.schema
         }}
      };
       
      
      public var attractors:Vector.<BattleAttractorDef>;
      
      public function BattleAttractorsDef()
      {
         this.attractors = new Vector.<BattleAttractorDef>();
         super();
      }
      
      public function get hasAttractorDefs() : Boolean
      {
         return this.numAttractors > 0;
      }
      
      public function get numAttractors() : int
      {
         return !!this.attractors ? this.attractors.length : 0;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleAttractorsDef
      {
         var _loc3_:Object = null;
         var _loc4_:BattleAttractorDef = null;
         for each(_loc3_ in param1.attractors)
         {
            _loc4_ = new BattleAttractorDef().fromJson(_loc3_,param2);
            this.addAttractor(_loc4_,false);
         }
         return this;
      }
      
      public function toJson() : Object
      {
         return {"attractors":ArrayUtil.defVectorToArray(this.attractors,true)};
      }
      
      public function clone() : BattleAttractorsDef
      {
         return new BattleAttractorsDef().fromJson(this.toJson(),null);
      }
      
      public function addAttractor(param1:BattleAttractorDef, param2:Boolean = true) : void
      {
         this.attractors.push(param1);
         param1.attractorDefs = this;
         if(param2)
         {
            this.notifyAttractorAdded(param1);
         }
      }
      
      public function removeAttractor(param1:BattleAttractorDef) : void
      {
         var _loc2_:String = param1.id;
         var _loc3_:int = this.attractors.indexOf(param1);
         if(_loc3_ >= 0)
         {
            this.attractors.splice(_loc3_,1);
         }
         this.notifyAttractorRemoved(_loc2_);
      }
      
      public function visitAttractorDefs(param1:Function) : void
      {
         var _loc2_:BattleAttractorDef = null;
         for each(_loc2_ in this.attractors)
         {
            param1(_loc2_);
         }
      }
      
      public function findAttractorDef(param1:Function) : BattleAttractorDef
      {
         var _loc2_:BattleAttractorDef = null;
         for each(_loc2_ in this.attractors)
         {
            if(param1(_loc2_))
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function findAttractorForLocation(param1:TileLocation) : BattleAttractorDef
      {
         var tl:TileLocation = param1;
         return this.findAttractorDef(function(param1:BattleAttractorDef):Boolean
         {
            return param1.rect.contains(tl._x,tl._y);
         });
      }
      
      public function notifyAttractorAdded(param1:BattleAttractorDef) : void
      {
         dispatchEvent(new BattleAttractorDefsEvent(BattleAttractorDefsEvent.EVENT_ADDED,param1,null));
      }
      
      public function notifyAttractorRemoved(param1:String) : void
      {
         dispatchEvent(new BattleAttractorDefsEvent(BattleAttractorDefsEvent.EVENT_REMOVED,null,param1));
      }
      
      public function notifyAttractorChanged(param1:BattleAttractorDef) : void
      {
         dispatchEvent(new BattleAttractorDefsEvent(BattleAttractorDefsEvent.EVENT_CHANGED,param1,null));
      }
      
      public function notifyAttractorRectChanged(param1:BattleAttractorDef) : void
      {
         dispatchEvent(new BattleAttractorDefsEvent(BattleAttractorDefsEvent.EVENT_RECT,param1,null));
      }
   }
}
