package game.cfg
{
   import engine.core.gp.GpBinder;
   
   public class GameGpBinder extends GpBinder
   {
       
      
      private var config:GameConfig;
      
      public function GameGpBinder(param1:GameConfig, param2:int)
      {
         super(param1.shell,param1.logger);
         this.config = param1;
      }
   }
}
