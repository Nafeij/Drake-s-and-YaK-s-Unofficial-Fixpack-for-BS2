package game.gui.page
{
   import game.session.actions.VsType;
   
   public interface IGuiGreatHallListener
   {
       
      
      function guiGreatHallFriend() : void;
      
      function guiGreathallVersus(param1:VsType, param2:int) : void;
      
      function guiGreatHallSkirmish() : void;
      
      function guiGreatHallNarrative() : void;
      
      function guiGreatHallExit() : void;
      
      function guiGoToProvingGrounds() : void;
   }
}
