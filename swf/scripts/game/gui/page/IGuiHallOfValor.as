package game.gui.page
{
   import game.gui.IGuiContext;
   import tbs.srv.data.LeaderboardsData;
   
   public interface IGuiHallOfValor
   {
       
      
      function init(param1:IGuiContext, param2:IGuiHallOfValorListener) : void;
      
      function updateLeaderboards(param1:LeaderboardsData) : void;
   }
}
