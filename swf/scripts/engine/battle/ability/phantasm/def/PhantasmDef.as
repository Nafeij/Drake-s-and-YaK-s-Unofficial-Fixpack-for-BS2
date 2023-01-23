package engine.battle.ability.phantasm.def
{
   import engine.battle.ability.effect.def.BooleanValueReqs;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import flash.errors.IllegalOperationError;
   
   public class PhantasmDef
   {
       
      
      public var time:int;
      
      public var targetMode:PhantasmTargetMode;
      
      public var animTrigger:PhantasmAnimTriggerDef;
      
      public var guaranteed:Boolean;
      
      public var sync:String;
      
      public var casterTagReqs:EffectTagReqs = null;
      
      public var effectTagReqs:EffectTagReqs = null;
      
      public var targetTagReqs:EffectTagReqs = null;
      
      public var largeTargetReq:BooleanValueReqs = null;
      
      public var directionalFlags:int = 0;
      
      public function PhantasmDef()
      {
         super();
      }
      
      public function toJson() : Object
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function toString() : String
      {
         return "time=" + this.time + " target=" + this.targetMode + " trigger=" + this.animTrigger + " sync=" + this.sync;
      }
   }
}
