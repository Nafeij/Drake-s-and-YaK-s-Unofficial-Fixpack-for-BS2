package game.view.tutorial
{
   import game.gui.page.MeadHousePage;
   import game.gui.page.ProvingGroundsPage;
   import game.gui.page.ScenePage;
   import game.gui.page.TownPage;
   import game.gui.page.VideoPage;
   import game.session.states.tutorial.TutorialBattleState;
   import game.session.states.tutorial.TutorialMeadHouseState;
   import game.session.states.tutorial.TutorialProvingGroundsState;
   import game.session.states.tutorial.TutorialTownFinishState;
   import game.session.states.tutorial.TutorialTownState;
   import game.session.states.tutorial.TutorialVideoPart1State;
   import game.session.states.tutorial.TutorialVideoPart2State;
   import game.view.GamePageManagerAdapter;
   
   public class RegisterTutorialPages
   {
       
      
      public function RegisterTutorialPages()
      {
         super();
      }
      
      public static function register(param1:GamePageManagerAdapter) : void
      {
         param1.registerFsmStatePageClass(TutorialVideoPart1State,VideoPage);
         param1.registerFsmStatePageClass(TutorialVideoPart2State,VideoPage);
         param1.registerFsmStatePageClass(TutorialBattleState,ScenePage);
         param1.registerFsmStatePageClass(TutorialTownState,TownPage);
         param1.registerFsmStatePageClass(TutorialMeadHouseState,MeadHousePage);
         param1.registerFsmStatePageClass(TutorialProvingGroundsState,ProvingGroundsPage);
         param1.registerFsmStatePageClass(TutorialTownFinishState,TownPage);
      }
   }
}
