package engine.battle.ability.phantasm.model
{
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import flash.events.Event;
   
   public class PhantasmsEvent extends Event
   {
      
      public static const CHAIN_STARTED:String = "CombatPhantasmsEvent.CHAIN_STARTED";
      
      public static const CHAIN_REMOVED:String = "CombatPhantasmsEvent.CHAIN_REMOVED";
       
      
      public var chain:ChainPhantasms;
      
      public var def:ChainPhantasmsDef;
      
      public function PhantasmsEvent(param1:String, param2:ChainPhantasms, param3:ChainPhantasmsDef)
      {
         super(param1);
         this.chain = param2;
         this.def = !!param2 ? param2.def : param3;
      }
   }
}
