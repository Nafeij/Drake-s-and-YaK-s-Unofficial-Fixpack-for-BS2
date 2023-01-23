package engine.battle
{
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.entity.model.BattleEntityMobility;
   import engine.battle.fsm.aimodule.AiGlobalConfig;
   import engine.core.render.CameraDrifter;
   import engine.saga.SagaCheat;
   import engine.saga.action.Action_Wait;
   
   public class Fastall
   {
      
      public static var gui:Boolean;
       
      
      public function Fastall()
      {
         super();
      }
      
      public static function set fastall(param1:Boolean) : void
      {
         BattleEntityMobility.FAST_FORWARD = param1;
         Action_Wait.DISABLE = param1;
         ChainPhantasms.FAST_ATTACK = param1;
         AiGlobalConfig.FAST = param1;
         CameraDrifter.FAST = param1;
         gui = param1;
         if(param1)
         {
            SagaCheat.devCheat("fastall");
         }
      }
      
      public static function get fastall() : Boolean
      {
         return BattleEntityMobility.FAST_FORWARD && Action_Wait.DISABLE && ChainPhantasms.FAST_ATTACK && AiGlobalConfig.FAST && CameraDrifter.FAST && gui;
      }
   }
}
