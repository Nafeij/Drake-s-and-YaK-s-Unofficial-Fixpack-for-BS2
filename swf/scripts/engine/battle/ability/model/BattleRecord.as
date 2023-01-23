package engine.battle.ability.model
{
   import engine.stat.model.IStatHistoryTurnProvider;
   import engine.stat.model.StatHistoryTimeline;
   
   public class BattleRecord implements IStatHistoryTurnProvider
   {
       
      
      private var strengthDamageDone:StatHistoryTimeline;
      
      private var armorDamageDone:StatHistoryTimeline;
      
      private var willpowerDamageDone:StatHistoryTimeline;
      
      private var strengthDamageTaken:StatHistoryTimeline;
      
      private var armorDamageTaken:StatHistoryTimeline;
      
      private var willpowerDamageTaken:StatHistoryTimeline;
      
      private var kills:StatHistoryTimeline;
      
      private var _turn:int;
      
      public function BattleRecord(param1:Boolean = false)
      {
         super();
         if(!param1)
         {
            this.strengthDamageDone = new StatHistoryTimeline(this);
            this.armorDamageDone = new StatHistoryTimeline(this);
            this.strengthDamageTaken = new StatHistoryTimeline(this);
            this.armorDamageTaken = new StatHistoryTimeline(this);
            this.willpowerDamageTaken = new StatHistoryTimeline(this);
            this.kills = new StatHistoryTimeline(this);
         }
      }
      
      public function get turn() : int
      {
         return this._turn;
      }
      
      public function nextTurn() : void
      {
         ++this._turn;
      }
      
      public function addStrengthDamageDone(param1:int) : void
      {
         if(this.strengthDamageDone)
         {
            this.strengthDamageDone.addDelta(param1);
         }
      }
      
      public function addArmorDamageDone(param1:int) : void
      {
         if(this.armorDamageDone)
         {
            this.armorDamageDone.addDelta(param1);
         }
      }
      
      public function addWillpowerDamageDone(param1:int) : void
      {
         if(this.willpowerDamageDone)
         {
            this.willpowerDamageDone.addDelta(param1);
         }
      }
      
      public function addStrengthDamageTaken(param1:int) : void
      {
         if(this.strengthDamageTaken)
         {
            this.strengthDamageTaken.addDelta(param1);
         }
      }
      
      public function addArmorDamageTaken(param1:int) : void
      {
         if(this.armorDamageTaken)
         {
            this.armorDamageTaken.addDelta(param1);
         }
      }
      
      public function addWillpowerDamageTaken(param1:int) : void
      {
         if(this.willpowerDamageTaken)
         {
            this.willpowerDamageTaken.addDelta(param1);
         }
      }
      
      public function addKills(param1:int) : void
      {
         if(this.kills)
         {
            this.kills.addDelta(param1);
         }
      }
   }
}
