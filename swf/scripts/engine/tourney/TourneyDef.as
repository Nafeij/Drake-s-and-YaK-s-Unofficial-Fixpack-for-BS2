package engine.tourney
{
   import engine.def.BooleanVars;
   
   public class TourneyDef
   {
       
      
      public var name:String;
      
      public var rewards:Vector.<int>;
      
      public var entry_fee:int;
      
      public var daily_limit:int;
      
      public var power_requirement:int;
      
      public var enabled:Boolean;
      
      public function TourneyDef()
      {
         this.rewards = new Vector.<int>();
         super();
      }
      
      public function fromJson(param1:Object) : void
      {
         var _loc2_:Object = null;
         this.name = param1.name;
         for each(_loc2_ in param1.rewards)
         {
            this.rewards.push(_loc2_);
         }
         this.entry_fee = param1.entry_fee;
         this.daily_limit = param1.daily_limit;
         this.power_requirement = param1.power_requirement;
         this.enabled = BooleanVars.parse(param1.enabled,true);
      }
   }
}
