package engine.battle.music
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class BattleMusicStateDef
   {
      
      public static const schema:Object = {
         "name":"BattleMusicStateDef",
         "properties":{
            "id":{"type":"string"},
            "event":{"type":"string"},
            "paramName":{
               "type":"string",
               "optional":true
            },
            "paramValue":{
               "type":"number",
               "optional":true
            },
            "outro":{
               "type":"string",
               "optional":true
            },
            "retain":{
               "type":"boolean",
               "optional":true
            },
            "ringout":{
               "type":"boolean",
               "optional":true
            },
            "durationMs":{
               "type":"number",
               "optional":true
            },
            "queueNext":{
               "type":"string",
               "optional":true
            },
            "allowQueueDuplicate":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var sku:String;
      
      private var _event:String;
      
      public var paramName:String;
      
      public var paramValue:Number = 0;
      
      public var outro:String;
      
      public var queueNext:String;
      
      public var retain:Boolean;
      
      public var ringout:Boolean;
      
      public var durationMs:int = 0;
      
      public var allowQueueDuplicate:Boolean = false;
      
      public function BattleMusicStateDef()
      {
         super();
      }
      
      public static function save(param1:BattleMusicStateDef) : Object
      {
         var _loc2_:Object = {
            "id":param1.id,
            "event":param1.event
         };
         if(param1.paramName)
         {
            _loc2_.paramName = param1.paramName;
            _loc2_.paramValue = param1.paramValue;
         }
         if(param1.outro)
         {
            _loc2_.outro = param1.outro;
         }
         if(param1.queueNext)
         {
            _loc2_.queueNext = param1.queueNext;
         }
         if(param1.ringout)
         {
            _loc2_.ringout = param1.ringout;
         }
         if(param1.retain)
         {
            _loc2_.retain = param1.retain;
         }
         if(param1.durationMs)
         {
            _loc2_.durationMs = param1.durationMs;
         }
         if(param1.allowQueueDuplicate)
         {
            _loc2_.allowQueueDuplicate = param1.allowQueueDuplicate;
         }
         return _loc2_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleMusicStateDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.event = param1.event;
         this.paramName = param1.paramName;
         this.outro = param1.outro;
         this.queueNext = param1.queueNext;
         this.durationMs = param1.durationMs;
         if(param1.paramValue != undefined)
         {
            this.paramValue = param1.paramValue;
         }
         this.retain = BooleanVars.parse(param1.retain,this.retain);
         this.ringout = BooleanVars.parse(param1.ringout,this.ringout);
         if(param1.allowQueueDuplicate != undefined)
         {
            this.allowQueueDuplicate = param1.allowQueueDuplicate;
         }
         return this;
      }
      
      public function get event() : String
      {
         return this._event;
      }
      
      public function set event(param1:String) : void
      {
         this._event = param1;
         if(this._event)
         {
            if(this._event.indexOf("saga1") == 0)
            {
               this.sku = "saga1";
               return;
            }
            if(this._event.indexOf("saga2") == 0)
            {
               this.sku = "saga2";
               return;
            }
            if(this._event.indexOf("saga3") == 0)
            {
               this.sku = "saga3";
               return;
            }
         }
         this.sku = "common";
      }
   }
}
