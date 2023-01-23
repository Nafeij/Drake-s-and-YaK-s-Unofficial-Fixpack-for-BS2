package engine.saga.happening
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.expression.Parser;
   import engine.saga.SagaTriggerDef;
   import engine.saga.SagaTriggerDefVars;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionDefVars;
   
   public class HappeningDefVars extends HappeningDef
   {
      
      public static const schema:Object = {
         "name":"HappeningDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "random":{
               "type":"boolean",
               "optional":true
            },
            "actions":{
               "type":"array",
               "items":ActionDefVars.schema
            },
            "triggers":{
               "type":"array",
               "items":SagaTriggerDefVars.schema,
               "optional":true
            },
            "keepalive":{
               "type":"boolean",
               "optional":true
            },
            "transcendent":{
               "type":"boolean",
               "optional":true
            },
            "global":{
               "type":"boolean",
               "optional":true
            },
            "automatic":{
               "type":"boolean",
               "optional":true
            },
            "enabled":{
               "type":"boolean",
               "optional":true
            },
            "prereq":{
               "type":"string",
               "optional":true
            },
            "outliveBattle":{
               "type":"boolean",
               "optional":true
            },
            "allow_saves":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function HappeningDefVars(param1:HappeningDefBag)
      {
         super(param1);
      }
      
      public static function save(param1:HappeningDef) : Object
      {
         var r:Object = null;
         var ad:ActionDef = null;
         var std:SagaTriggerDef = null;
         var rhs:HappeningDef = param1;
         try
         {
            r = {
               "id":rhs.id,
               "actions":[]
            };
            if(rhs.random)
            {
               r.random = true;
            }
            for each(ad in rhs.actions)
            {
               r.actions.push(ActionDefVars.save(ad));
            }
            if(Boolean(rhs.triggers) && rhs.triggers.list.length > 0)
            {
               r.triggers = [];
               for each(std in rhs.triggers.list)
               {
                  r.triggers.push(SagaTriggerDefVars.save(std));
               }
            }
            if(rhs.keepalive)
            {
               r.keepalive = true;
            }
            if(rhs.automatic)
            {
               r.automatic = true;
            }
            if(rhs.prereq)
            {
               r.prereq = rhs.prereq;
            }
            if(!rhs.transcendent)
            {
               r.transcendent = rhs.transcendent;
            }
            if(rhs.outliveBattle)
            {
               r.outliveBattle = rhs.outliveBattle;
            }
            if(rhs.allow_saves)
            {
               r.allow_saves = rhs.allow_saves;
            }
            if(!rhs.enabled)
            {
               r.enabled = rhs.enabled;
            }
            return r;
         }
         catch(e:Error)
         {
            throw new ArgumentError("Failed to save happening: " + rhs.id + "\n" + e.getStackTrace());
         }
      }
      
      public function fromJson(param1:Object, param2:ILogger, param3:Boolean) : HappeningDefVars
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:ActionDefVars = null;
         var _loc7_:SagaTriggerDefVars = null;
         var _loc8_:Parser = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         id = param1.id;
         random = BooleanVars.parse(param1.random,random);
         for each(_loc4_ in param1.actions)
         {
            _loc6_ = new ActionDefVars(this);
            _loc6_.fromJson(_loc4_,param2);
            if(!(param3 && !_loc6_.enabled))
            {
               addActionDef(_loc6_);
            }
         }
         if(param3)
         {
            if(actions.length > 0)
            {
            }
         }
         for each(_loc5_ in param1.triggers)
         {
            _loc7_ = new SagaTriggerDefVars(this,triggers);
            _loc7_.fromJson(_loc5_,param2);
            triggers.addTriggerDef(_loc7_);
         }
         keepalive = BooleanVars.parse(param1.keepalive,keepalive);
         if(param1.global != undefined)
         {
            automatic = BooleanVars.parse(param1.global,automatic);
         }
         else
         {
            automatic = BooleanVars.parse(param1.automatic,automatic);
         }
         prereq = param1.prereq;
         transcendent = BooleanVars.parse(param1.transcendent,transcendent);
         outliveBattle = BooleanVars.parse(param1.outliveBattle,outliveBattle);
         allow_saves = param1.allow_saves;
         enabled = BooleanVars.parse(param1.enabled,enabled);
         if(prereq)
         {
            if(prereq.indexOf("$triggering") == 0)
            {
               prereq = prereq;
            }
            _loc8_ = new Parser(prereq,param2);
            exp_prereq = _loc8_.exp;
            if(!exp_prereq)
            {
               throw new ArgumentError("Failed to parse prereq [" + prereq + "] for " + this);
            }
         }
         return this;
      }
   }
}
