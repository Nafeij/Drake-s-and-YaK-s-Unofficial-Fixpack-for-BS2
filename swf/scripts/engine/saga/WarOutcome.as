package engine.saga
{
   public class WarOutcome
   {
       
      
      public var type:WarOutcomeType;
      
      public var casualties_peasants:int;
      
      public var casualties_fighters:int;
      
      public var casualties_varl:int;
      
      public var threat:int;
      
      public var injuries:Vector.<String>;
      
      public var renown:int;
      
      public var renown_clansmen:int;
      
      public var clansmen_saved:int;
      
      public var unitsReadyToPromote:Vector.<String>;
      
      public var unitsInjured:Vector.<String>;
      
      public function WarOutcome()
      {
         this.injuries = new Vector.<String>();
         this.unitsReadyToPromote = new Vector.<String>();
         this.unitsInjured = new Vector.<String>();
         super();
      }
   }
}
