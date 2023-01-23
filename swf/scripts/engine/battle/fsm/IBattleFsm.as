package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.fsm.IFsm;
   import engine.session.Session;
   
   public interface IBattleFsm extends IFsm
   {
       
      
      function get aborted() : Boolean;
      
      function get turn() : IBattleTurn;
      
      function get order() : IBattleTurnOrder;
      
      function abortBattle(param1:Boolean) : void;
      
      function noticeInjury(param1:String) : void;
      
      function get battleFinished() : Boolean;
      
      function nextTurnSuspend() : void;
      
      function nextTurnResume() : void;
      
      function get participants() : Vector.<IBattleEntity>;
      
      function get finishedData() : BattleFinishedData;
      
      function get unitsReadyToPromote() : Vector.<String>;
      
      function get unitsInjured() : Vector.<String>;
      
      function get halted() : Boolean;
      
      function get interact() : IBattleEntity;
      
      function set interact(param1:IBattleEntity) : void;
      
      function get cleanedup() : Boolean;
      
      function get respawnedBattle() : Boolean;
      
      function get localBattleOrder() : int;
      
      function get session() : Session;
      
      function get activeEntity() : IBattleEntity;
      
      function get waveDeploymentEnabled() : Boolean;
      
      function transitionTo(param1:Class, param2:Object) : void;
      
      function getBoard() : IBattleBoard;
      
      function skipTurn(param1:String, param2:Boolean) : void;
   }
}
