package engine.battle.ability.effect.model
{
   import engine.core.util.Enum;
   
   public class AddEffectResponse extends Enum
   {
      
      public static const FAILED:AddEffectResponse = new AddEffectResponse("FAILED",enumCtorKey);
      
      public static const SUCCESS:AddEffectResponse = new AddEffectResponse("SUCCESS",enumCtorKey);
      
      public static const DELAY:AddEffectResponse = new AddEffectResponse("DELAY",enumCtorKey);
       
      
      public function AddEffectResponse(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
