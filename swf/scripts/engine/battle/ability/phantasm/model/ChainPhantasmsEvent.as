package engine.battle.ability.phantasm.model
{
   import engine.battle.ability.phantasm.def.PhantasmDef;
   import flash.events.Event;
   
   public class ChainPhantasmsEvent extends Event
   {
      
      public static const STARTED:String = "ChainPhantasmsEvent.STARTED";
      
      public static const APPLIED:String = "ChainPhantasmsEvent.APPLIED";
      
      public static const ENDED:String = "ChainPhantasmsEvent.ENDED";
      
      public static const PHANTASM:String = "ChainPhantasmsEvent.PHANTASM";
       
      
      public var chain:ChainPhantasms;
      
      public var phantasmDef:PhantasmDef;
      
      public function ChainPhantasmsEvent(param1:String, param2:ChainPhantasms, param3:PhantasmDef)
      {
         super(param1);
         this.chain = param2;
         this.phantasmDef = param3;
      }
   }
}
