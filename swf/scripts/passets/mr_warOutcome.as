package passets
{
   import flash.display.MovieClip;
   import game.gui.battle.GuiWarOutcome;
   
   public dynamic class mr_warOutcome extends GuiWarOutcome
   {
       
      
      public var casualtiesFighters:mr_spearText;
      
      public var casualtiesPeasants:mr_spearText;
      
      public var casualtiesVarl:mr_spearText;
      
      public var injuries:mr_spearText;
      
      public var kills:mr_spearText;
      
      public var skullPopups:MovieClip;
      
      public var winBonus:mr_spearText;
      
      public var winIcon:mr_winBonusPopups;
      
      public function mr_warOutcome()
      {
         super();
      }
   }
}
