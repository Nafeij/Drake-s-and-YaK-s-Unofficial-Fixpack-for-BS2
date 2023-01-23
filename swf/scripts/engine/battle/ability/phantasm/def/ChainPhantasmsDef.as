package engine.battle.ability.phantasm.def
{
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.effect.model.EffectPhase;
   import engine.battle.ability.effect.model.EffectResult;
   import flash.utils.Dictionary;
   
   public class ChainPhantasmsDef
   {
       
      
      public var applyTriggers:Vector.<PhantasmAnimTriggerDef>;
      
      public var endTriggers:Vector.<PhantasmAnimTriggerDef>;
      
      public var applyTime:int;
      
      public var applyTimeVariance:int;
      
      public var startDelay:int;
      
      public var endTime:int;
      
      public var entries:Vector.<PhantasmDef>;
      
      public var timedEntries:Vector.<PhantasmDef>;
      
      public var results:Dictionary;
      
      public var results_vars:Array;
      
      private var resultCount:int;
      
      public var waitEffect:IEffectDef;
      
      public var waitEffectPhase:EffectPhase;
      
      public var rotation:Boolean = true;
      
      public var reverseRotation:Boolean;
      
      public var animTriggerEntriesMap:Dictionary;
      
      public function ChainPhantasmsDef()
      {
         this.applyTriggers = new Vector.<PhantasmAnimTriggerDef>();
         this.endTriggers = new Vector.<PhantasmAnimTriggerDef>();
         this.entries = new Vector.<PhantasmDef>();
         this.timedEntries = new Vector.<PhantasmDef>();
         this.results = new Dictionary();
         this.animTriggerEntriesMap = new Dictionary();
         super();
      }
      
      protected function addResult(param1:EffectResult) : void
      {
         this.results[param1] = param1;
         ++this.resultCount;
      }
      
      public function isResultOk(param1:EffectResult) : Boolean
      {
         if(this.resultCount <= 0)
         {
            return true;
         }
         if(this.results[param1] != null)
         {
            return true;
         }
         return false;
      }
   }
}
