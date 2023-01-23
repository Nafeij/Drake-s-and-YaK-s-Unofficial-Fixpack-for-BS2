package engine.battle.fsm.aimodule
{
   public class AiPlanConsts
   {
      
      public static const WEIGHT_KILL:int = 200;
      
      public static const WEIGHT_MAIM:int = 600;
      
      public static const WEIGHT_STAR_ABILITY:int = 10;
      
      public static const WEIGHT_STAR_MOVE:int = 40;
      
      public static const WEIGHT_SELF_THREAT:Number = 0.5;
      
      public static const WEIGHT_ENEMY_THREAT:Number = 0.25;
      
      public static const WEIGHT_ABL_DAMAGE_STR:int = 45;
      
      public static const WEIGHT_ABL_DAMAGE_ARM:int = 20;
      
      public static const WEIGHT_ABL_MISSCHANCE:int = 25;
      
      public static const WEIGHT_FRIEND_DISTANCE:int = 5;
      
      public static const WEIGHT_ATTRACTOR_DISTANCE:int = 55;
      
      public static const WEIGHT_ENEMY_DISTANCE:int = 10;
      
      public static const WEIGHT_WILLPOWER_DOMINANCE:int = 100;
      
      public static const WEIGHT_MOVE:int = -2;
      
      public static const WEIGHT_BACK_OFF:int = 60;
      
      public static const WEIGHT_PROP:int = -300;
      
      public static const WEIGHT_HAZARD:int = -200;
       
      
      public function AiPlanConsts()
      {
         super();
      }
   }
}
