package engine.saga
{
   import engine.core.logging.ILogger;
   
   public class SagaCampMusicEntryDef
   {
      
      public static const schema:Object = {
         "name":"SagaCampMusicEntryDef",
         "type":"object",
         "properties":{
            "event":{"type":"string"},
            "acv":{
               "type":"string",
               "optional":true
            },
            "conditional_if":{
               "type":"string",
               "optional":true
            },
            "weight":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var event:String;
      
      public var acv:String;
      
      public var conditional_if:String;
      
      public var weight:int;
      
      public function SagaCampMusicEntryDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaCampMusicEntryDef
      {
         this.event = param1.event;
         this.acv = param1.acv;
         this.conditional_if = param1.conditional_if;
         this.weight = param1.weight;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {"event":(!!this.event ? this.event : "")};
         if(this.acv)
         {
            _loc1_.acv = this.acv;
         }
         if(this.conditional_if)
         {
            _loc1_.conditional_if = this.conditional_if;
         }
         if(this.weight > 1)
         {
            _loc1_.weight = this.weight;
         }
         return _loc1_;
      }
      
      public function isValid(param1:Saga) : Boolean
      {
         if(this.acv)
         {
            if(!SagaAchievements.isUnlocked(this.acv))
            {
               return false;
            }
         }
         if(this.conditional_if)
         {
            return param1.expression.evaluate(this.conditional_if,true) != 0;
         }
         return true;
      }
   }
}
