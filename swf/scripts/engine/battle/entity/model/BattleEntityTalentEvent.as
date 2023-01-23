package engine.battle.entity.model
{
   import engine.battle.board.model.IBattleEntity;
   import engine.talent.TalentDef;
   import flash.events.Event;
   
   public class BattleEntityTalentEvent extends Event
   {
      
      public static var EXECUTED:String = "BattleEntityTalentEvent.EXECUTED";
       
      
      public var entity:IBattleEntity;
      
      public var talentDef:TalentDef;
      
      public function BattleEntityTalentEvent(param1:IBattleEntity, param2:TalentDef)
      {
         super(EXECUTED);
         this.entity = param1;
         this.talentDef = param2;
      }
   }
}
