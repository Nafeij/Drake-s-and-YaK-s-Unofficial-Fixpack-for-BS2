package game.gui.battle
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import game.gui.IGuiContext;
   
   public interface IGuiInitiative
   {
       
      
      function init(param1:IGuiContext, param2:IGuiInitiativeListener, param3:Vector.<IEntity>) : void;
      
      function setInitiativeEntities(param1:Vector.<IBattleEntity>, param2:Boolean, param3:IBattleEntity) : void;
      
      function set timerPercent(param1:Number) : void;
      
      function clearEndButton() : void;
      
      function interact(param1:IBattleEntity, param2:Boolean, param3:Boolean) : void;
      
      function set turnCommitted(param1:Boolean) : void;
      
      function get infobar() : IGuiBattleInfo;
      
      function get waveTurnCounter() : IGuiWaveTurnCounter;
      
      function resizehandler(param1:Number, param2:Number) : void;
      
      function displayLowOnTime(param1:Number, param2:Number) : void;
      
      function cleanup() : void;
      
      function updateDisplayLists() : void;
      
      function getPositionForEntity(param1:IBattleEntity) : Point;
      
      function get movieClip() : MovieClip;
      
      function handleOptionsShowing(param1:Boolean) : void;
      
      function get authorSize() : Point;
      
      function get suppressVisible() : Boolean;
      
      function set suppressVisible(param1:Boolean) : void;
      
      function update(param1:int) : void;
   }
}
