package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import game.session.GameFsm;
   import game.session.states.TownLoadState;
   
   public class RegisterTutorialStates
   {
       
      
      public function RegisterTutorialStates()
      {
         super();
      }
      
      public static function register(param1:GameFsm) : void
      {
         param1.registerState(TutorialStartState);
         param1.registerState(TutorialLoadPartyState);
         param1.registerState(TutorialVideoPart1State);
         param1.registerState(TutorialVideoPart2State);
         param1.registerState(TutorialBattleLoadState);
         param1.registerState(TutorialBattleLoadDirectState);
         param1.registerState(TutorialBattleState);
         param1.registerState(TutorialTownState);
         param1.registerState(TutorialTownLoadState);
         param1.registerState(TutorialTownFinishState);
         param1.registerState(TutorialMeadHouseState);
         param1.registerState(TutorialProvingGroundsState);
         param1.registerState(TutorialEndState);
         param1.registerTransition(TutorialStartState,TutorialLoadPartyState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialLoadPartyState,TutorialBattleLoadState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialBattleLoadState,TutorialVideoPart1State,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialVideoPart1State,TutorialBattleState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialBattleLoadDirectState,TutorialBattleState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialBattleState,TutorialVideoPart2State,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialVideoPart2State,TutorialTownLoadState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialTownLoadState,TutorialTownState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialTownState,TutorialMeadHouseState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialMeadHouseState,TutorialProvingGroundsState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialProvingGroundsState,TutorialTownFinishState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialTownFinishState,TutorialEndState,Fsm.TRANS_COMPLETE);
         param1.registerTransition(TutorialEndState,TownLoadState,Fsm.TRANS_ALL);
         param1.registerTransition(TutorialStartState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialLoadPartyState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialBattleLoadState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialVideoPart1State,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialBattleLoadDirectState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialBattleState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialVideoPart2State,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialTownLoadState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialTownState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialMeadHouseState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialProvingGroundsState,TutorialEndState,Fsm.TRANS_FAILED);
         param1.registerTransition(TutorialTownFinishState,TutorialEndState,Fsm.TRANS_FAILED);
      }
   }
}
