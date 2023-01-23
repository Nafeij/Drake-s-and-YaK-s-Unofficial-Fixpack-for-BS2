package game.gui.page
{
   import engine.saga.convo.Convo;
   import game.cfg.GameConfig;
   
   public class WarPage extends PoppeningPage
   {
      
      public static var mcClazzWar:Class;
       
      
      public function WarPage(param1:GameConfig, param2:Convo)
      {
         super(param1,param2);
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mcClazzWar);
      }
   }
}
