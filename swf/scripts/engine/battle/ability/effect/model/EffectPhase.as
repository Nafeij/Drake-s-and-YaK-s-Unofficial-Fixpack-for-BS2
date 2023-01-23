package engine.battle.ability.effect.model
{
   import engine.core.util.Enum;
   
   public class EffectPhase extends Enum
   {
      
      public static const EXECUTING:EffectPhase = new EffectPhase("EXECUTING",0,enumCtorKey);
      
      public static const EXECUTED:EffectPhase = new EffectPhase("EXECUTED",1,enumCtorKey);
      
      public static const APPLYING:EffectPhase = new EffectPhase("APPLYING",2,enumCtorKey);
      
      public static const APPLIED:EffectPhase = new EffectPhase("APPLIED",3,enumCtorKey);
      
      public static const COMPLETED:EffectPhase = new EffectPhase("COMPLETED",4,enumCtorKey);
      
      public static const REMOVING:EffectPhase = new EffectPhase("REMOVING",5,enumCtorKey);
      
      public static const REMOVED:EffectPhase = new EffectPhase("REMOVED",6,enumCtorKey);
      
      public static const INVALID:EffectPhase = new EffectPhase("INVALID",7,enumCtorKey);
       
      
      private var _index:int;
      
      public function EffectPhase(param1:String, param2:int, param3:Object)
      {
         super(param1,param3);
         this._index = param2;
      }
      
      public function get index() : int
      {
         return this._index;
      }
   }
}
