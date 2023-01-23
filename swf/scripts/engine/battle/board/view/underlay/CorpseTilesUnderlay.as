package engine.battle.board.view.underlay
{
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.board.view.DirtyRenderSprite;
   
   public class CorpseTilesUnderlay extends DirtyRenderSprite
   {
       
      
      public function CorpseTilesUnderlay(param1:BattleBoardView)
      {
         super(param1);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override protected function onRender() : void
      {
      }
   }
}
